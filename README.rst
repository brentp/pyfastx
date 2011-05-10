pyfastx: unified access to FASTA and FASTX sequence files
=========================================================


Usage
=====

::

    >>> from pyfastx import FastX, FastXIter
    >>> fa = FastXIter('pyfastx/test/data/key.fasta')
    >>> for record in fa:
    ...    record.name, record.seq, record.qual
    ('a extra', 'AAaa', None)
    ('b extra', 'AAbb', None)
    ('c extra', 'AAcc', None)


    >>> fa = FastX('pyfastx/test/data/key.fasta')
    >>> list(fa)
    [BROKEN]


    # or a dictionary.
    #>>> header = fxz.iterkeys().next()
    #>>> print fxz[header]
    <SequenceRecord>
