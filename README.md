## Capstone Project: Identifying Potential Biomarkers for Colorectal Cancer

## Overview
This project aims to identify potential biomarkers for colorectal cancer (CRC) using transcriptomic data analysis. We utilized a dataset from the Gene Expression Omnibus (GEO) repository, specifically GSE4107, which includes RNA samples from the colonic mucosa of 22 patients (12 with cancer and 10 controls).

## Project Roadmap - Methods

 1. Data Collection and Preprocessing

- Acquired data from GEO.
- Performed quality control and normalization using RMA (Robust Multi-array Average) method.

 2. Statistical Analysis

- Identified differentially expressed genes (DEGs) using the Limma package.
- Visualized top DEGs with heatmaps and volcano plots.

3. Functional Analysis

- Conducted enrichment analysis using the clusterProfiler package.
- Analyzed KEGG pathways and gene ontology networks.

4. Validation using Relevant Literature
- Investigated the biological significance and clinical relevance of top DEGs.
- Focused on FOS, VIP, and CCN1 as potential biomarkers.

## Key R Packages Used
clusterProfiler for enrichment analysis
GEOquery for accessing GEO data
Limma for differential expression analysis
Affy for processing Affymetrix array data
AnnotationDbi for gene annotation
EnrichPlot for visualizing enrichment results

## Data Analysis Results

Quality Control and Visualization
 * Normalization: Applied RMA normalization to ensure data consistency.  
 * Principal Component Analysis (PCA): Conducted PCA to assess sample variability and clustering.

Differential Expression Analysis: Identified top 10 DEGs, with a focus on:
* CCN1 (Cyr61)
* FOS
* VIP

Functional Analysis:
* KEGG Pathways: Identified enriched pathways such as fluid shear stress and atherosclerosis, proteoglycans in cancer, and complement and coagulation cascades.
* Gene Ontology Network: Mapped gene interactions and biological processes.

Literature Research:
* FOS: Associated with cell differentiation and tumor formation, higher risk of CRC.
* VIP: Anti-inflammatory role in colonic tumorigenesis.
* CCN1: Promotes CRC cell proliferation, invasion, and metastasis; potential early-stage biomarker.

## Conclusion
This capstone project successfully identified several potential biomarkers for CRC. The integration of statistical analysis, functional enrichment, and literature research provides a comprehensive approach to understanding the molecular mechanisms of colorectal cancer and identifying targets for early diagnosis and therapy.
