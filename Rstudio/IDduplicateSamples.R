library(vcfR)
library(pbapply)
library(ggplot2)
library(stringr)


#function to compare genotypes between all pairs of samples
#input format: rows are loci, columns are samples, alleles are 0 and 1, missing genotypes are NA
#heterozygous calls must be consistent within a locus, ie all 0/1, no 1/0
IDduplicateSamples<-function(genotypes,MAF=NULL){
  #function to calculate MAF
  calcMAF<-function(locusGenos){
    allele1Counts<-sum(str_count(locusGenos,"0"),na.rm=TRUE)
    allele2Counts<-sum(str_count(locusGenos,"1"),na.rm=TRUE)
    allele1Freq<-allele1Counts/sum(allele1Counts,allele2Counts)
    if(allele1Freq>0.5){
      MAF<-1-allele1Freq
    }else{
      MAF<-allele1Freq
    }
    return(MAF)
  }
  
  #filter loci using MAF if threshold is specified
  if(!is.null(MAF)){
    #calculate MAF
    message(paste("MAF threshold applied:",MAF,"MAF",sep=" "))
    message("calculating MAF")
    locusMAF<-pbapply(genotypes,1,calcMAF)
    #convert to dataframe
    locusMAF<-data.frame(locus_ID=names(locusMAF),MAF=locusMAF,row.names=NULL)
    locusMAF$locus_ID<-as.character(locusMAF$locus_ID)
    #filter loc based on MAF threshold
    genotypes<-genotypes[rownames(genotypes)%in%locusMAF$locus_ID[locusMAF$MAF>=MAF],]
  }else{
    message("No MAF threshold applied, using all loci")
  }
  
  #make matrix of called vs NA genotypes for faster counting of missing data
  genotypes_NAmatrix<-genotypes
  genotypes_NAmatrix[!is.na(genotypes_NAmatrix)]<-0
  genotypes_NAmatrix[is.na(genotypes_NAmatrix)]<-1
  class(genotypes_NAmatrix)<-"numeric"
  
  #identify all unique pairs of samples
  allPairs<-combn(dim(genotypes)[2], 2)
  ncombo<-dim(allPairs)[2]
  nloci<-dim(genotypes)[1]
  message(paste("number of samples:",dim(genotypes)[2],sep=" "))
  message(paste("number of loci:",nloci,sep=" "))
  message(paste("number of sample pairs:",ncombo,sep=" "))
  #reshape into 2xn matrix
  allPairs<-matrix(allPairs,nrow=2)
  #count number of shared (not NA) genotypes
  #use this as denominator when calculating proportion of shared genotypes
  message("finding shared genotypes")
  commonGenos<-pbapply(allPairs,2,function(x){NAcounts<-genotypes_NAmatrix[,x[1]]+genotypes_NAmatrix[,x[2]]
                                              sharedCounts<-nloci-(sum(NAcounts)-sum(NAcounts[NAcounts==2])/2)})
  
  
  #do all pairwise sample comparisons
  message("comparing genotypes")
  matches<-pbapply(allPairs,2,function(x) sum(genotypes[,x[1]]==genotypes[,x[2]],na.rm=TRUE))

  #make dataframe of results
  comparisonResults<-data.frame(matrix(NA,nrow=dim(allPairs)[2],ncol=7))
  colnames(comparisonResults)<-c("Sample1","Sample2","matchedGenotypes","commonGenotypes","proportionMatch","proportionCommon","totalLoci")
  comparisonResults$Sample1<-colnames(genotypes)[allPairs[1,]]
  comparisonResults$Sample2<-colnames(genotypes)[allPairs[2,]]
  comparisonResults$matchedGenotypes<-matches
  comparisonResults$commonGenotypes<-commonGenos
  comparisonResults$proportionMatch<-comparisonResults$matchedGenotypes/comparisonResults$commonGenotypes
  comparisonResults$proportionCommon<-comparisonResults$commonGenotypes/nloci
  comparisonResults$totalLoci<-nloci
  return(comparisonResults)
}


#load vcf file
vcfData<-read.vcfR("I:/DATA/ChinookRAD/populations/example.vcf")

#extract genotypes
genotypes<-extract.gt(vcfData, element = "GT", mask = FALSE, as.numeric = FALSE,
                      return.alleles = FALSE, IDtoRowNames = TRUE, extract = TRUE,
                      convertNA = TRUE)

#compare sample genotypes with no MAF threshold
IDdupResults<-IDduplicateSamples(genotypes)
#compare sample genotypes with MAF threshold of 0.05
IDdupResults_MAF05<-IDduplicateSamples(genotypes,MAF=0.05)

#plot distribution of percent identity with no MAF threshold
ggplot()+geom_histogram(data=IDdupResults,aes(x=proportionMatch),binwidth=0.01)
#plot distribution of percent identity with MAF threshold of 0.05
ggplot()+geom_histogram(data=IDdupResults_MAF05,aes(x=proportionMatch),binwidth=0.01)
#plot percent identity vs proportion of loci genotyped in both samples with no MAF threshold
ggplot()+geom_point(data=IDdupResults,aes(x=proportionCommon,y=proportionMatch),alpha=0.1)
#plot percent identity vs proportion of loci genotyped in both samples with MAF threshold of 0.05
ggplot()+geom_point(data=IDdupResults_MAF05,aes(x=proportionCommon,y=proportionMatch),alpha=0.1)