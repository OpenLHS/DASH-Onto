## Customize Makefile settings for DASH-Onto
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

# Custom reports exported in csv rather than tsv

SPARQL_CSTM_EXPORTS_ARGS = $(foreach V,$(SPARQL_EXPORTS),-s $(SPARQLDIR)/$(V).sparql $(REPORTDIR)/$(V).csv)


.PHONY: custom_reports
custom_reports: $(EDIT_PREPROCESSED) | $(REPORTDIR)
ifneq ($(SPARQL_EXPORTS_ARGS),)
	$(ROBOT) query --use-graphs true -i $< $(SPARQL_CSTM_EXPORTS_ARGS)
endif

# Command for building doc without GitHub publish

build_docs:
	mkdocs build --config-file ../../mkdocs.yaml

create_extract_from_release:
	#$(ROBOT) query -i $(RELEASEDIR)/$(ONT)-non-classified.owl --query $(SPARQLDIR)/list-ontorel-classes.sparql $(RELEASEDIR)/ontorel/tempfolder/ontorel-classes-list.txt
	$(ROBOT) filter -i $(RELEASEDIR)/$(ONT).owl -T $(RELEASEDIR)/RRDS_extraction/IRI_list.txt --select "self annotations" --trim false \
	annotate --ontology-iri "http://purl.obolibrary.org/obo/$(ONT)/$(ONT)_extract-fist-pass.owl" -o $(RELEASEDIR)/RRDS_extraction/tempfolder/$(ONT)_extract-first-pass.owl
	$(ROBOT) query -i $(RELEASEDIR)/RRDS_extraction/tempfolder/$(ONT)_extract-first-pass.owl --query $(SPARQLDIR)/list-all-classes-and-properties.sparql $(RELEASEDIR)/RRDS_extraction/tempfolder/classes-and-properties-list.txt
	$(ROBOT) filter -i $(RELEASEDIR)/$(ONT).owl -T $(RELEASEDIR)/RRDS_extraction/tempfolder/classes-and-properties-list.txt --select "self annotations" --trim true \
	annotate --ontology-iri "http://purl.obolibrary.org/obo/$(ONT)/$(ONT)_extract-second-pass.owl" -o $(RELEASEDIR)/RRDS_extraction/tempfolder/$(ONT)_extract-second-pass.owl
	$(ROBOT) merge -i $(RELEASEDIR)/RRDS_extraction/tempfolder/$(ONT)_extract-first-pass.owl -i $(RELEASEDIR)/RRDS_extraction/tempfolder/$(ONT)_extract-second-pass.owl \
	relax \
	annotate --ontology-iri "http://purl.obolibrary.org/obo/$(ONT)/$(ONT)_RRDS_extraction.owl" -o $(RELEASEDIR)/RRDS_extraction/$(ONT)_RRDS_extraction.owl
