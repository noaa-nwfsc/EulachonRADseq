# EulachonRADseq
Multi-year Eulachon RAD-seq analysis

Current status: files have been de-multiplexed, aligned to genome, processed through stacks and output VCF file. VCFvisuals.html is preliminary look at coverage for individuals and sites and a rough filtered VCF (filtered individuals with missingness > 0.5, individuals that are duplicated between old and new, and site missingness <0.5, and variants with MAF <0.05 )

Next Steps:
-  Explore batch effects where possible
-  combine oldNEB and newNEB alignments in analysis
-  Remove 51889.9_Elwha which was identified as longfin smelt by Krista (COI results)
-  Identify duplicates (51985.7 and 51985.8 from Klamath) - combine ? or remove 1
-  Re-run stacks and populations with these changes, include variant call quality scores in output
