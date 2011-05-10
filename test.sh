python setup.py build_ext -i && \
PYTHONPATH=$PYTHONPATH:. nosetests-2.7 --with-doctest --doctest-extension=.rst README.rst
