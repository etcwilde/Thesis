# Masters thesis makefile
# Evan Wilde <etcwilde@uvic.ca>
# Aug 16, 2017

# Directories
DIR_OUTPUT   = output/
DIR_CHAPTERS = chapters/
DIR_FIGURES  = Figures/
DIR_TABLES   = Tables/
DIR_MACROS   = macros/
DIR_FRONT    = frontmatter/
DIR_SCRIPTS	 = scripts/

# Files
template = $(wildcard $(DIR_FRONT)*.tex $(DIR_MACROS)*.tex)
mainfile = thesis.tex
chapters = $(wildcard $(DIR_CHAPTERS)*.tex)
figures  = $(wildcard $(DIR_FIGURES)*.tex $(DIR_FIGURES)*.pdf $(DIR_FIGURES)*.png)
tables   = $(wildcard $(DIR_TABLES)*.tex)

figures += $(DIR_FIGURES)linux_commits_per_year.pdf \
		   $(DIR_FIGURES)linux_commits_per_release.pdf \
		   $(DIR_FIGURES)linux_authors_per_release.pdf \
		   $(DIR_FIGURES)linux_merge_distribution_per_release.pdf

$(info Compiling Main File: $(mainfile))
$(info Compiling Chapters:  $(chapters))
$(info Compiling Figures:   $(figures))
$(info Compiling Tables:    $(tables))

# Phony Targets
.PHONY: all clean clean-full

all: $(DIR_OUTPUT)Thesis.pdf

clean:
	rubber --clean thesis
	rm -f thesis.synctex thesis.synctex.gz
	rm -f thesis.brf
	rm -f thesis.lot thesis.lof thesis.toc

clean-full: clean
	rm -r $(DIR_OUTPUT)

# Directory Target
$(DIR_OUTPUT):
	mkdir -p $(DIR_OUTPUT)

# Primary targets
$(DIR_OUTPUT)Thesis.pdf: $(DIR_OUTPUT) $(mainfile) $(chapters) $(figures) $(tables)
	rubber --pdf $(mainfile)
	mv thesis.pdf $(DIR_OUTPUT)Thesis.pdf

$(DIR_FIGURES)linux_commits_per_year.pdf: $(DIR_SCRIPTS)linux/commit_counts.R
	./$(DIR_SCRIPTS)linux/commit_counts.R
	mv per_year.pdf $(DIR_FIGURES)linux_commits_per_year.pdf
	mv per_release.pdf $(DIR_FIGURES)linux_commits_per_release.pdf
	mv merge_distribution.pdf $(DIR_FIGURES)linux_merge_distribution_per_release.pdf

$(DIR_FIGURES)linux_commits_per_release.pdf: $(DIR_SCRIPTS)linux/commit_counts.R
	./$(DIR_SCRIPTS)linux/commit_counts.R
	mv per_year.pdf $(DIR_FIGURES)linux_commits_per_year.pdf
	mv per_release.pdf $(DIR_FIGURES)linux_commits_per_release.pdf
	mv merge_distribution.pdf $(DIR_FIGURES)linux_merge_distribution_per_release.pdf

$(DIR_FIGURES)linux_merge_distribution_per_release.pdf: $(DIR_SCRIPTS)linux/commit_counts.R
	./$(DIR_SCRIPTS)linux/commit_counts.R
	mv per_year.pdf $(DIR_FIGURES)linux_commits_per_year.pdf
	mv per_release.pdf $(DIR_FIGURES)linux_commits_per_release.pdf
	mv merge_distribution.pdf $(DIR_FIGURES)linux_merge_distribution_per_release.pdf


$(DIR_FIGURES)linux_authors_per_release.pdf: $(DIR_SCRIPTS)linux/author_counts.R
	./$(DIR_SCRIPTS)linux/author_counts.R
	mv authors_per_release.pdf $(DIR_FIGURES)linux_authors_per_release.pdf
