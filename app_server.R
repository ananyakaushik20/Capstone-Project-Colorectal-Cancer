####QUALITY CONTROL######
  
  
  #Reactive value to store data after normalization and/or batch correction
  final_qc_dat<-reactiveVal()
  

  
  #Normalization of data
  observeEvent(input$normlzdata,
               {
                 if(is.null(celdat()) && is.null(data()) && is.null(geo_data())){
                   final_qc_dat(NULL)
                 }
                 else{
                   if(input$normlztype=="RMA" && input$oligo=="Affymetrix Human Genome U133 Plus 2.0 Array"){
                     norm_affy<-exprs(affy::rma(celdat()))
                     colnames(norm_affy)<-plot_samplenames()
                     final_qc_dat(norm_affy)
                     output$norm_comp<-renderText("Background correction, normalization, and summarization have been performed.")
                   }
                   else if(input$normlztype=="GCRMA"  && input$oligo=="Affymetrix Human Genome U133 Plus 2.0 Array"){
                     norm_affy<-exprs(gcrma(celdat()))
                     colnames(norm_affy)<-plot_samplenames()
                     final_qc_dat(norm_affy)
                     output$norm_comp<-renderText("Background correction, normalization, and summarization have been performed.")
                   }
                   else if(input$normlztype=="MAS5" && input$oligo=="Affymetrix Human Genome U133 Plus 2.0 Array"){
                     norm_affy<-log(exprs(mas5(celdat())),2)
                     colnames(norm_affy)<-plot_samplenames()
                     final_qc_dat(norm_affy)
                     output$norm_comp<-renderText("Background correction, normalization, and summarization have been performed.")
                   }
                   else if(input$normlztype=="RMA" && (input$oligo=="Affymetrix Human Gene 1.0 ST Array" )){
                     norm_affy<-exprs(oligo::rma(celdat()))
                     colnames(norm_affy)<-plot_samplenames()
                     final_qc_dat(norm_affy)
                     output$norm_comp<-renderText("Background correction, normalization, and summarization have been performed.")
                   }
                   else if(input$normlztype=="GCRMA" && is.null(geo_data()) && (input$oligo=="Affymetrix Human Gene 1.0 ST Array" || input$oligo=="Affymetrix Human Exon 1.0 ST Array")){
                     norm_affy<-NULL
                     final_qc_dat(norm_affy)
                   }
                   else if(input$normlztype=="MAS5" && is.null(geo_data()) && (input$oligo=="Affymetrix Human Gene 1.0 ST Array" || input$oligo=="Affymetrix Human Exon 1.0 ST Array")){
                     norm_affy<-NULL
                     final_qc_dat(norm_affy)
                   }
                   
                 }
                 
               })
  
  #Dropdown selection for user to select which metadata column assigns each sample to batches
  output$batch_cat<-renderUI({
    selectInput("batch_feat","If samples come from different batches, specify which metadata feature indicates the batch each sample belongs to.",choices=colnames(meet())[-1])
  })
  
  #Perform batch correction if button pressed, update reactive value
  observeEvent(input$startbatch,{
    batch_cor_dat<-ComBat(final_qc_dat(),batch=meet()[,input$batch_feat])
    final_qc_dat(batch_cor_dat)
    output$batch_com<-renderText("Batch Correction is complete.")
  }
  )
  
  
  #Visualize data prior to normalization using RLE or NUSE
  observeEvent(input$vis_dat,{
    if(input$qc_method=="RLE" && input$oligo=="Affymetrix Human Genome U133 Plus 2.0 Array" && is.null(geo_data())){
      affy.data=fitPLM(celdat())
      output$plot_raw<-renderPlot({
        RLE(affy.data,main="Relative Log Expression of Samples",las=2,cex.axis=0.5,ylab="Expression Values",xlab="",xaxt="n")
        axis(1,at=1:length(rownames(affy.data@phenoData@data)),labels=plot_samplenames(),las=2,cex.axis=0.5)
        title(xlab="Sample Names",line=4)
        })
      
    }
    else if(input$qc_method=="NUSE" && input$oligo=="Affymetrix Human Genome U133 Plus 2.0 Array"&& is.null(geo_data())){
      affy.data=fitPLM(celdat())
      output$plot_raw<-renderPlot({NUSE(affy.data,main="Normalized Unscaled Standard Errors of Samples",las=2,cex.axis=0.5,ylab="Standard Error Values",xlab="",xaxt="n")
      axis(1,at=1:length(rownames(affy.data@phenoData@data)),labels=plot_samplenames(),las=2,cex.axis=0.5)
      title(xlab="Sample Names",line=4)})
    }
    
    else if(input$qc_method=="RLE" && (input$oligo=="Affymetrix Human Gene 1.0 ST Array" || input$oligo=="Affymetrix Human Exon 1.0 ST Array")&& is.null(geo_data())){
      oligo.data=oligo::fitProbeLevelModel(celdat())
      output$plot_raw<-renderPlot({oligo::RLE(oligo.data,main="Relative Log Expression of Samples",las=2,cex.axis=0.5,ylab="Expression Values",xlab="",xaxt="n")
      axis(1,at=1:length(rownames(oligo.data@protocolData@data)),labels=plot_samplenames(),las=2,cex.axis=0.5)
      title(xlab="Sample Names",line=4)})
      
    }
    
    else if(input$qc_method=="NUSE"&& (input$oligo=="Affymetrix Human Gene 1.0 ST Array" || input$oligo=="Affymetrix Human Exon 1.0 ST Array")&& is.null(geo_data())){
      oligo.data=oligo::fitProbeLevelModel(celdat())
      output$plot_raw<-renderPlot({oligo::NUSE(oligo.data,main="Normalized Unscaled Standard Errors of Samples",las=2,cex.axis=0.5,ylab="Standard Error Values",xlab="",xaxt="n")
      axis(1,at=1:length(rownames(oligo.data@protocolData@data)),labels=plot_samplenames(),las=2,cex.axis=0.5)
      title(xlab="Sample Names",line=4)})
    }
    else if(input$qc_method=="PCA"){
      pcacomps_raw<-prcomp(exprs(celdat()),center=FALSE,scale=FALSE)
      comps_raw<-pcacomps_raw$rotation
      output$pc_comp_raw<-renderUI({
        selectInput("compraw","Which components do you want to plot?",choices=colnames(comps_raw),multiple=TRUE)
      })
      output$feat_raw<-renderUI({
        selectInput("featcolraw","Which feature do you want to group samples by?",choices=colnames(meet())[-1])
      })
      output$pcplot_raw_button<-renderUI({
        actionButton("pcplot_raw","Plot Principal Components")
      })
    }
    else if(input$qc_method=="Boxplot" && input$oligo=="Affymetrix Human Genome U133 Plus 2.0 Array" && is.null(geo_data())){
      output$plot_raw<-renderPlot({boxplot(celdat(),xlab="",ylab="Gene Expression Values",main="Boxplot of Gene Expression for Each Sample",cex.axis=0.5,las=2,xaxt="n")
        axis(1,at=1:length(plot_samplenames()),labels=plot_samplenames(),las=2,cex.axis=0.5)
        title(xlab="Sample Names",line=4)})
    }
    else if(input$qc_method=="Boxplot" && input$oligo=="Affymetrix Human Gene 1.0 ST Array" && is.null(geo_data())){
      output$plot_raw<-renderPlot({
        databox<-celdat()
        boxplot(fitProbeLevelModel(databox),xlab="",ylab="Gene Expression Values",main="Boxplot of Gene Expression for Each Sample",cex.axis=0.5,las=2,xaxt="n")
        axis(1,at=1:length(plot_samplenames()),labels=plot_samplenames(),las=2,cex.axis=0.5)
        title(xlab="Sample Names",line=4)})
    }
  })
  
  observeEvent(input$pcplot_raw,{
    if(length(input$compraw)>2){
      output$pcwarnraw<-renderText("Please only select two principal components.")
    }
    else if (length(input$compraw)<2){
      output$pcwarnraw<-renderText("Please select two principal components.")
    }
    if(is.null(input$featcolraw)){
      output$pcwarnraw<-renderText("Please specify a feature to group samples by.")
    }
    else{
      output$pcwarnraw<-NULL
      pcacomps1raw<-prcomp(exprs(celdat()),center=FALSE,scale=FALSE)
      comps1raw<-pcacomps1raw$rotation
      input_compraw<-as.vector(input$compraw)
      pcsraw<-comps1raw[,input_compraw]
      pc1raw<-pcsraw[,1]
      pc2raw<-pcsraw[,2]
      colorsraw<-meet()[,input$featcolraw]
      data_to_plotraw<-data.frame(pc1raw,pc2raw,colorsraw)
      praw<-ggplot(data_to_plotraw,aes(x=pc1raw,y=pc2raw,color=colorsraw))+stat_ellipse()
      praw<-praw+geom_point()+labs(color=input$featcolraw)+ggtitle("PCA Plot for Raw Data")+xlab(input$compraw[1])+ylab(input$compraw[2])
      met_info<-meet()
      #met_info<-met_info[-1,]
      praw<-praw+geom_text(aes(label=met_info[,1]),hjust=0,vjust=0,size=4)
      output$plot_raw<-renderPlot(praw)
    }
  })
  
  #Visualize normalized data using Boxplot or PCA
  observeEvent(input$vis_button,{
    if(input$qc_method2=="Boxplot"){
      output$qcplot<-renderPlot({
        boxplot(final_qc_dat(),xlab="",ylab="Gene Expression Values",main="Boxplot of Gene Expression for Each Sample",cex.axis=0.5,las=2,xaxt="n",yaxt="n")
        axis(1,at=1:length(plot_samplenames()),labels=plot_samplenames(),las=2,cex.axis=0.5)
        title(xlab="Sample Names",line=4)
      })
    }
    else if(input$qc_method2=="PCA"){
      pcacomps<-prcomp(final_qc_dat(),center=FALSE,scale=FALSE)
      comps<-pcacomps$rotation
      output$pc_comp<-renderUI({
        selectInput("comp_plot","Which components do you want to plot?",choices=colnames(comps),multiple=TRUE)
      })
      output$feat<-renderUI({
        selectInput("feat_color","Which feature do you want to group samples by?",choices=colnames(meet())[-1])
      })
      
    }
  })
  
  #Specify Principal Components and Colors for PCA
  observeEvent(input$pcplot,{
    if(length(input$comp_plot)>2){
      output$pcwarn<-renderText("Please only select two principal components.")
    }
    else if (length(input$comp_plot)<2){
      output$pcwarn<-renderText("Please select two principal components.")
    }
    if(is.null(input$feat_color)){
      output$pcwarn<-renderText("Please specify a feature to group samples by.")
    }
    else{
      output$pcwarn<-NULL
      pcacomps1<-prcomp(final_qc_dat(),center=FALSE,scale=FALSE)
      comps1<-pcacomps1$rotation
      input_comp<-as.vector(input$comp_plot)
      pcs<-comps1[,input_comp]
      pc1<-pcs[,1]
      pc2<-pcs[,2]
      colors<-meet()[,input$feat_color]
      data_to_plot<-data.frame(pc1,pc2,colors)
      p<-ggplot(data_to_plot,aes(x=pc1,y=pc2,color=colors))+stat_ellipse()
      p<-p+geom_point()+labs(color=input$feat_color)+ggtitle("PCA Plot for Normalized Data")+xlab(input$comp_plot[1])+ylab(input$comp_plot[2])
      met_2<-meet()
      p<-p+geom_text(aes(label=met_2[,1]),hjust=0,vjust=0,size=4)
      output$qcplot<-renderPlot(p)
    }
  })
  
  
  
  #Outliers
  observeEvent(input$getout,{
    
    #Find outliers
    outlier_affy<-outliers(final_qc_dat(),method=as.vector(input$outmethod))
    #output$potout<-renderText(as.vector(names(outlier_affy@which)))
    values<-outlier_affy@statistic
    dat_fram<-data.frame(colnames(final_qc_dat()),values)
    #Visualize outlier statistic value for each sample
    p<-ggplot(data=dat_fram,aes(x=dat_fram[,1],y=dat_fram[,2]))+geom_col()+geom_hline(yintercept=outlier_affy@threshold)+ggtitle("Potential Outliers")+labs(y="Value of Selected Statistic",x="Sample")+scale_x_discrete(guide = guide_axis(check.overlap = TRUE))+theme(axis.text.x=element_text(angle=90),axis.text.y=element_text(angle=90))
    output$outplot<-renderPlot({
      p
    })
    output$remove<-renderUI(selectInput("torem","Select outlier candidates you would like to remove.",multiple=TRUE,choices=as.list(names(outlier_affy@which))))})
    #Remove outliers and update expression matrix
    observeEvent(input$update,{
      expr_mat_2<-final_qc_dat()
      meta_datframe<-meta_data()
      for(name in input$torem){
        sample_names<-colnames(expr_mat_2)
        ind_to_remove<-which(sample_names==name)
        expr_mat_2<-expr_mat_2[,-ind_to_remove]
        meta_sample_names=meta_datframe[,1]
        meta_ind_to_remove<-which(meta_sample_names==name)
        meta_datframe<-meta_datframe[-meta_ind_to_remove,]
      }
      #Update reactive value
      final_qc_dat(expr_mat_2)
      meta_data(meta_datframe)
      #Table of expression data with outlier samples removed
      output$newexprs<-renderDataTable({
        matr<-final_qc_dat()
        veccolnames<-colnames(matr)
        veccoltodatfram<-as.data.frame(veccolnames)
        datatable(veccoltodatfram,extensions = c('Responsive'), class = 'cell-border stripe',
                  options = list(pageLength = 10,responsive = TRUE),
                  colnames=c('Sample Index','Sample Name'))
        })
    })

  
  
  observeEvent(input$grouped, {
    updateTabItems(session, "tabs", "degAnalysis")
  }
  )
  
  
  ####STATISTICAL ANALYSIS####
  #Data Annotation
  
  data_for_an<-reactive({
    if(is.null(data())==FALSE){
      qc_dat<-as.data.frame(data())
      row.names(qc_dat)<-qc_dat[,1]
      qc_dat<-qc_dat[,-1]
      return(qc_dat)
    }
    else if(is.null(geo_data())==FALSE){
      
      gn1<-geo_data()
      return(as.data.frame(exprs(gn1[[1]])))
    }
    
    else if(is.null(celdat())==FALSE){
      qc_dat<-final_qc_dat()
      qc_dat<-as.data.frame(qc_dat,row.names=rownames(qc_dat))
      return(qc_dat)
    }
    
    else{
      return(NULL)
    }
  })
  annotated_data <- reactive({
    if(is.null(data_for_an())){
      return(NULL)}
    else{
      
      data_stat<-data_for_an()
      #Get gene symbols from hgu133plus.db
      if(input$oligo=="Affymetrix Human Gene 1.0 ST Array"){
        symbols<-AnnotationDbi::select(hugene11sttranscriptcluster.db, keys=row.names(data_stat), columns=c("SYMBOL"))
      }
      else{
        symbols<-AnnotationDbi::select(hgu133plus2.db, keys=row.names(data_stat), columns=c("SYMBOL"))
      }
      
      #Remove duplicate ProbeIDs
      symbols <- symbols[!duplicated(symbols$PROBEID),]
      data_stat$sym<-symbols$SYMBOL
      
      #Remove NA values
      data_stat<-na.omit(data_stat)
      
      
      #Remove duplicate gene symbols
      new_sym<-data_stat$sym
      data_stat<-data_stat[,-which(colnames(data_stat)=="sym")]
      data_stat<-collapseRows(data_stat,rowGroup=new_sym,rowID=rownames(data_stat))
      expr_dat_frame2<-as.data.frame(data_stat$datETcollapsed)
      return(expr_dat_frame2)
      
    }
  })
  
  
  filtered_dat<-NULL
  
  #Filter genes with low levels of expression
  observeEvent(input$filt_gen,filtered_dat<-({
    dat_for_filter<-annotated_data()
    gene_means<-rowMeans(dat_for_filter)
    perc<-as.numeric(quantile(gene_means, probs=(input$cutoff/100), na.rm=T))
    dat_for_filter[which(gene_means >= perc),]
    output$gen_filt<-renderText({"The genes have been filtered."})
  }))
  
  
  #Adds to UI features of samples from metadata, user can select which features they wish to compare based on
  output$col_selection<-renderUI({
    selectInput("col_int","Select the feature you wish to analyze for differential gene expression.",choices=colnames(meet())[-1])
  })
  
  
  #Find DEGs
  desmat1<-reactiveVal()
  final_result<-eventReactive(input$degs,{
    
    #Data to use based on if user filtered data or not
    if(is.null(filtered_dat)){
      dat_for_stat<-annotated_data()
    }
    else{
      dat_for_stat<-filtered_dat
    }
    met_dat<-meta_data()
    index_col<-which(colnames(met_dat)==input$col_int)
    variable<-factor(met_dat[,index_col])
    des_matrix<-model.matrix(~0+variable,met_dat)
    desmat1(des_matrix)
    colnames(des_matrix)<-c("Factor_a","Factor_b")
    
    fitting<-lmFit(dat_for_stat,des_matrix)
    fac1<-colnames(as.data.frame(des_matrix))[1]
    fac2<-colnames(as.data.frame(des_matrix))[2]
    phr<-c(paste(fac1,fac2,sep="-"))
    con_mat<-makeContrasts(contrasts=phr,levels=des_matrix)
    fit.contrast<-contrasts.fit(fitting,con_mat)
    stat.con<-eBayes(fit.contrast)
    result<-topTable(stat.con,sort.by="p",p.value=input$p_val,lfc=input$fc_cut,number=length(rownames(dat_for_stat)))
    lfc2<-result$logFC
    for(lfcval_index in 1:length(lfc2)){
      if(length(lfc2)==0){
        result<-result
      }
      else if(abs(as.integer(lfc2[lfcval_index]))< abs(as.integer(input$fc_cut))){
        result<-result[-c(lfcval_index),] %>% head()
      }
    }
    
    dimension<-dim(result)
    if(dimension[1]==0){
      des_matrix<-model.matrix(~variable,met_dat)
      colnames(des_matrix)<-c("Factor_a","Factor_b")
      fitting<-lmFit(dat_for_stat,des_matrix)
      fac1<-colnames(as.data.frame(des_matrix))[1]
      fac2<-colnames(as.data.frame(des_matrix))[2]
      phr<-c(paste(fac1,fac2,sep="-"))
      con_mat<-makeContrasts(contrasts=phr,levels=des_matrix)
      fit.contrast<-contrasts.fit(fitting,con_mat)
      stat.con<-eBayes(fit.contrast)
      result<-topTable(stat.con,sort.by="p",p.value=input$p_val,lfc=input$fc_cut,number=length(rownames(dat_for_stat)))
      lfc2<-result$logFC
      for(lfcval_index in 1:length(lfc2)){
        if(abs(lfc2[lfcval_index]) < abs(input$fc_cut)){
          result<-result[-c(lfcval_index),] %>% head()
        }
      }
      #output$error<-renderPrint({c(result,result[-1,],lfc2,1:length(lfc2))})
    }
    result
  }
  )
  
  output$toptab<-renderDT({
    datatable(final_result(),extensions = c('Responsive','Buttons'), class = 'cell-border stripe',
              options = list(order = list(5, 'asc'),
                             pageLength = 10,responsive = TRUE))
  })
  
  
  #Reactive Volcano Plot inputs
  volcano_p<-reactive({as.numeric(input$m)})
  volcano_fc<-reactive({as.numeric(input$n)})
  
  observeEvent(input$degs,{
    output$plot1 <- renderPlot({
      if(is.null(final_result)){
        NULL
      }
      else{
        result_to_plot<-final_result()
        if(input$labs_volc==TRUE){
        EnhancedVolcano(data.frame(result_to_plot),lab=rownames(data.frame(result_to_plot)),
                        x='logFC',y='P.Value',
                        title='Volcano Plot of DEGs',
                        pCutoff=volcano_p(), FCcutoff=volcano_fc(),
                        xlab = bquote(~Log[2] ~ "fold change"),
                        ylab = bquote(~-Log[10] ~ italic(P)),pCutoffCol=which(colnames(result_to_plot)=="adj.P.Val"))}
        else{
          EnhancedVolcano(data.frame(result_to_plot),
                          x='logFC',y='P.Value',
                          title='Volcano Plot of DEGs',
                          pCutoff=volcano_p(), lab=NA, FCcutoff=volcano_fc(),
                          xlab = bquote(~Log[2] ~ "fold change"),
                          ylab = bquote(~-Log[10] ~ italic(P)),pCutoffCol=which(colnames(result_to_plot)=="adj.P.Val"))
        }
      }})})
  
  
  
  
  ######FUNCTIONAL ANALYSIS######
  
  genelist<-reactive({
    gene_table<-final_result()
    GSEA.entrez <- AnnotationDbi::select(org.Hs.eg.db, keys=rownames(data.frame(gene_table)), columns=c("ENTREZID"),keytype="SYMBOL")
    GSEA.entrez <- GSEA.entrez[!duplicated(GSEA.entrez$SYMBOL),]
    row.names(GSEA.entrez) <- GSEA.entrez$SYMBOL
    GSEA.genes <- merge(GSEA.entrez, gene_table, by="row.names")
    genlist<-GSEA.genes$logFC
    names(genlist) <- GSEA.genes$ENTREZID
    genlist2 <- sort(genlist, decreasing=T)
    return(genlist2)
  })
  
  msig <- msigdbr(species="Homo sapiens", category="H")
  h <- msig %>% select(gs_name, entrez_gene)
  
  observeEvent(input$gsea,output$plot_gsea <- renderPlot({
    gsea <- GSEA(genelist(), TERM2GENE=h,eps=0)
    #c("genelist",genelist(),"gsea",gsea)
    gseaplot2(gsea, geneSetID=1:length(gsea$enrichmentScore), pvalue_table=TRUE,title="GSEA Results")
  }))
  
  
  eKegg <- reactive({
    gene_entrez<-genelist()
    enrichKEGG(gene = names(gene_entrez), organism = "hsa",pvalueCutoff=input$KEGG_pcut)
  })
  max_kegg<-reactive({
    #if(is.null(eKegg)){
      return(20)
    #}
    # else{
    #   enrichobj<-eKegg()
    #   nrow(enrichobj@result)
    # }
  })
  output$kegg_y<-renderUI({
    sliderInput("y", "Number of pathways shown", 0, max_kegg(),
                value =10, step = 2)
  })
  observeEvent(input$kegg,{
    if(is.null(eKegg())){
      output$keggwarn<-renderText("There are no enriched pathways at this cutoff adjusted p-value.")
    }
    else{
      output$dotplot <- renderPlot(clusterProfiler::dotplot(eKegg(), showCategory = input$y))
    }
  })
  observeEvent(input$kegg, {
    if(is.null(eKegg())){
      output$barplot<-NULL
    }
    else{
      output$barplot <- renderPlot(barplot(eKegg(), showCategory = input$y))
    }
  })
  
  ont_cat<-reactive({
    if(input$type=="Cellular Components"){
      return("CC")
    }
    else if(input$type=="Molecular Functions"){
      return("MF")
    }
    else if(input$type=="Biological Processes"){
      return("BP")
    }
  })
