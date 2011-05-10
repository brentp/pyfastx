import os.path as op
from .kseq import KSeq, KFile, KFileIter



class FastX(object):
    def __init__(self, file_name, index=None):
        self.file_type, self.gzipped = FastX.guess_file_type(file_name)
        self.file_name = file_name

    @classmethod
    def guess_file_type(self):
        """
        return the filename, gzipped status of the file
        """
        
class SequenceRecord(object):
    def __init__(self, fh):
        pass

