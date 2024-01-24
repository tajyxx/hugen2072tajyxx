#!/bin/bash
#SBATCH --account=hugen2072_2024s

module load gcc/8.2.0 
module load bcftools/1.15.1 
module load vcftools/0.1.16
module load plink/1.90b6.7



#2. Copy data.vcf
cp /ix1/hugen2072_2024s/ca/data.vcf 

#3 + 4. Sort, index, filter to chr4  

bcftools sort data.vcf -Oz -o data4.vcf.gz 
bcftools index -t data4.vcf.gz
bcftools view data4.vcf.gz -Ob -o data4.bcf.gz -r 4


#5. create a PLINK binary file set version of data4.bcf.gz
plink --bcf data4.bcf.gz --make-bed --out data4 --allow-extra-chr

#6 + 7. Update sex
plink --bfile data4 --update-sex /ix1/hugen2072_2024s/ca/sex.txt --make-bed --out data4

#8. Case allele frequencies
plink --bfile data4 --freq --filter /ix1/hugen2072_2024s/ca/phenotype.txt '2' --out case_freq 

#9. Control frequencies  
plink --bfile data4 --freq --filter /ix1/hugen2072_2024s/ca/phenotype.txt '1' --out control_freq 

#10. GWAS
plink --bfile data4 --pheno /ix1/hugen2072_2024s/ca/phenotype.txt --assoc fisher --logistic --allow-no-sex --adjust --ci 0.95 --out gwas
