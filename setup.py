import glob
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext


exts = [ Extension("pyfastx.kseq",
              sources=["pyfastx/kseq.pyx"],
                   #+ glob.glob("src/*.h"),
              libraries=['z'],
              include_dirs=["src/"],
              depends = glob.glob("src/*.h"),
              language="c"),
        ]

setup( 
        name="pyfastx",
        ext_modules=exts,
        requires=['cython'],
        packages=['pyfastx','pyfastx.test'],
        author="Brent Pedersen",
        description='Unified Access to Fasta and FastX',
        url="none",
        package_data = {'pyfastx':['test/data/*', "*.pyx"]},
        package_dir = {"pyfastx": "pyfastx"},
        cmdclass = {'build_ext': build_ext},
        author_email="bpederse@gmail.com",
    )
