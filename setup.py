from distutils.core import setup
from Cython.Build import cythonize

setup(
    ext_modules=cythonize(["SpellChecker/*.pyx"],
                          compiler_directives={'language_level': "3"}),
    name='NlpToolkit-SpellChecker-Cy',
    version='1.0.4',
    packages=['SpellChecker'],
    package_data={'SpellChecker': ['*.pxd', '*.pyx', '*.c']},
    url='https://github.com/StarlangSoftware/TurkishSpellChecker-Cy',
    license='',
    author='olcaytaner',
    author_email='olcay.yildiz@ozyegin.edu.tr',
    description='Turkish Spell Checker Library',
    install_requires=['NlpToolkit-MorphologicalAnalysis-Cy', 'NlpToolkit-NGram-Cy']
)
