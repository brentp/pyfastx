import os.path as op
import sys

cdef extern from "string.h":
    void * memcpy(void * destination, void * source, size_t num)

cdef extern from "zlib.h":
    ctypedef struct gzFile:
        pass

    cdef int gzrewind(gzFile)
    cdef int gzdirect(gzFile) # 0/1 if un/compressed

    cdef int gzseek(gzFile f, size_t offset, int whence)

    cdef gzFile gzopen(char *fname, char *mode)
    cdef gzFile gzdopen(int fno, char *mode)
    cdef void gzclose(gzFile)

cdef extern from "stdio.h":
    int fileno(gzFile *stream)

cdef extern from "kseq.h":
    ctypedef struct kstring_t:
        size_t l, m
        char *s

    ctypedef struct kstream_t:
        char *buf
        int begin, end, is_eof
        gzFile f

    ctypedef struct kseq_t:
        kstring_t name, comment, seq, qual
        int last_char
        kstream_t *f

    cdef kseq_t* kseq_init(gzFile)
    cdef int kseq_read(kseq_t *)
    cdef void kseq_destroy(kseq_t *)


cdef class KFileBase:
    cdef gzFile fp
    cdef kseq_t* current_seq
    cdef int line_status

    def __init__(self, file_name):
        assert op.exists(file_name)
        self.fp = gzopen(file_name, "r")# if file_name != "-" else gzdopen(fileno(stdin), "r");

    def __iter__(self):
        gzseek(self.fp, 0, 0)
        self.current_seq = kseq_init(self.fp)
        return self

    def __destroy__(self):
        kseq_destroy(self.current_seq)
        gzclose(self.fp)

cdef class KFileIter(KFileBase):
    """
    KFileIter does only 1 malloc and re-uses that for each record. So so it is
    suitable for iterating over a file, but note for holding a series of
    records in memory
    """

    def __next__(self):
        cdef int l = kseq_read(self.current_seq)
        if l < 0: raise StopIteration
        cdef KSeqIter k = KSeqIter()
        k.kseq = self.current_seq
        return k

cdef class KFile(KFileBase):

    def __next__(self):
        cdef KSeq k = KSeq(self)
        l = kseq_read(self.current_seq)
        if l < 0: raise StopIteration
        memcpy(k.kseq, self.current_seq, sizeof(kseq_t) + self.current_seq.seq.l + self.current_seq.qual.l + 10)
        sys.stderr.write(str(k) + "\n")
        return k

cdef class KSeqIter:
    cdef kseq_t *kseq

    property name:
        def __get__(self):
            # kseq splits on first space in the name.
            name = self.kseq.name.s
            if self.kseq.comment.l == 0:
                return name
            comment = self.kseq.comment.s
            return name + " " + comment

    property qual:
        def __get__(self):
            if self.kseq.qual.l == 0:
                return None
            return self.kseq.qual.s

    property seq:
        def __get__(self):
            return self.kseq.seq.s

    def __repr__(self):
        return "KSeqIter(%s)" % self.name

cdef class KSeq(KSeqIter):
    def __cinit__(self, KFile kfile):
        self.kseq = kseq_init(kfile.fp)

    def __repr__(self):
        return "KSeq(%s)" % self.name

    def __destroy__(self):
        pass
        #kseq_destroy(self.kseq)
