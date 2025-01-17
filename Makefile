default: help

# Based on https://gist.github.com/lumengxi/0ae4645124cd4066f676
.PHONY: clean-pyc clean-build docs clean

define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT
BROWSER := python -c "$$BROWSER_PYSCRIPT"
PYTHON := ./venv/bin/python3
SYS_PYTHON := python3.8

# Don't descend into any .dirs or venv.  Use like '$(FIND_SKIP) -other -find -args'
FIND_SKIP := find -E . -regex './(\..*|venv).*' -prune -o
PROJECT_DIR := x7

help:
	@echo "clean - remove all build, test, coverage and Python artifacts"
	@echo "clean-build - remove build artifacts"
	@echo "clean-pyc - remove Python file artifacts"
	@echo "clean-test - remove test and coverage artifacts"
	@echo "init - install requirements.txt and dev-requirements.txt"
	@echo "lint - check style with flake8"
	@echo "test - run tests quickly with the default Python"
	@echo "test-all - run tests on every Python version with tox"
	@echo "coverage - check code coverage quickly with the default Python"
	@echo "docs - generate Sphinx HTML documentation, including API docs"
	@echo "release - package and upload a release"
	@echo "dist - package"
	@echo "install - install the package to the active Python's site-packages"

venv:
	$(SYS_PYTHON) -m venv venv

init: venv
	$(PYTHON) -m pip -q install --upgrade pip
	$(PYTHON) -m pip -q install -r requirements.txt
	$(PYTHON) -m pip -q install -r dev-requirements.txt

clean: clean-build clean-pyc clean-test

clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	$(FIND_SKIP) -name '*.egg-info' -exec rm -fr {} +
	$(FIND_SKIP) -name '*.egg' -exec rm -f {} +

clean-pyc:
	$(FIND_SKIP) -name '*.pyc' -exec rm -f {} +
	$(FIND_SKIP) -name '*.pyo' -exec rm -f {} +
	$(FIND_SKIP) -name '*~' -exec rm -f {} +
	$(FIND_SKIP) -name '__pycache__' -exec rm -fr {} +

clean-test:
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/

lint:
	$(PYTHON) -m flake8 --extend-ignore=E741 $(PROJECT_DIR) tests

test:
	$(PYTHON) -m unittest discover -s tests -t .

test-via-setup:
	$(PYTHON) setup.py test

test-all:
	tox

coverage:
	coverage run --source $(PROJECT_DIR) setup.py test
	coverage report -m
	coverage html
	$(BROWSER) htmlcov/index.html

docs:
	rm -f docs/$(PROJECT_DIR).rst
	rm -f docs/modules.rst
	sphinx-apidoc -o docs/ $(PROJECT_DIR)
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(BROWSER) docs/_build/html/index.html

servedocs: docs
	watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .

release: clean
	$(PYTHON) setup.py sdist upload
	$(PYTHON) setup.py bdist_wheel upload

upload-test: dist
	$(PYTHON) -m twine upload --repository testpypi dist/*

upload-prod: dist
	$(PYTHON) -m twine upload --repository pypi dist/*

dist: clean
	$(PYTHON) setup.py sdist
	$(PYTHON) setup.py bdist_wheel
	ls -l dist

install: clean
	$(PYTHON) setup.py install -n
