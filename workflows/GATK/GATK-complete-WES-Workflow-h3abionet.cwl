#!/usr/bin/env cwl-runner

class: Workflow
cwlVersion: v1.0

requirements:
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  reference:
    type: File
    doc: reference human genome file

  uncompressed_reference:
    type: File
    doc: reference human genome file

  reads:
    type: File[]?
    doc: files containing the paired end reads in fastq format required for bwa-mem

  bwa_output_name:
    type: string
    doc: name of bwa-mem output file

  bwa_read_group:
    type: string
    doc: read group

  bwa_threads:
    type: int
    doc: number of threads

  gatk_threads:
    type: int
    doc: number of threads

  samtools_threads:
    type: int
    doc: number of threads

  output_RefDictionaryFile:
    type: string
    doc: output file name for picard create dictionary command from picard toolkit

  samtools-view-isbam:
    type: boolean
    doc: boolean set to output bam file from samtools view

  samtools-index-bai:
    type: boolean
    doc: boolean set to output bam file from samtools view

  output_samtools-view:
    type: string
    doc: output file name for bam file generated by samtools view

  output_samtools-sort:
    type: string
    doc: output file name for bam file generated by samtools sort

  outputFileName_MarkDuplicates:
    type: string
    doc: output file name generated as a result of Markduplicates command from picard toolkit

  metricsFile_MarkDuplicates:
    type: string
    doc: metric file generated by MarkDupicates command listing duplicates

  readSorted_MarkDuplicates:
    type: string
    doc: set to be true showing that reads are sorted already

  removeDuplicates_MarkDuplicates:
    type: string
    doc: set to be true

  createIndex_MarkDuplicates:
    type: string
    doc: set to be true to create .bai file from Picard Mark Duplicates

  outputFileName_RealignTargetCreator:
    type: string
    doc: name of realignTargetCreator output file

  known_variant_db:
    type: File[]?
    doc: array of known variant files for realign target creator

  outputFileName_IndelRealigner:
    type: string
    doc: name of indelRealigner output file

  outputFileName_BaseRecalibrator:
    type: string
    doc: name of BaseRecalibrator output file

  outputFileName_PrintReads:
    type: string
    doc: name of PrintReads command output file

  outputFileName_HaplotypeCaller:
    type: string
    doc: name of Haplotype caller command output file

  dbsnp:
    type: File
    doc: vcf file containing SNP variations used for Haplotype caller

  tmpdir:
    type: string?
    doc: temporary dir for picard

  samtools-view-sambam:
    type: string?
    doc: temporary dir for picard

  covariate:
    type: string[]?
    doc: required for base recalibrator

  depth_omitIntervalStatistics:
    type: boolean?
    doc: Do not calculate per-interval statistics

  depth_omitDepthOutputAtEachBase:
    type: boolean?
    doc: Do not output depth of coverage at each base

  depth_outputfile_DepthOfCoverage:
    type: string?
    doc: name of the output report basename

  filter_expression:
    type: string
    default: "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0"

  snpf_genome:
    type: string

  snpf_nodownload:
    type: boolean

  snpf_data_dir:
    type: Directory

  resource_mills:
    type: File

  resource_hapmap:
    type: File

  resource_omni:
    type: File

  resource_dbsnp:
    type: File

outputs:

  output_bamstat:
    type: File
    outputSource: HaplotypeCaller/output_bamstat

  output_printReads:
    type: File
    outputSource: HaplotypeCaller/output_printReads

  output_HaplotypeCaller:
    type: File
    outputSource: HaplotypeCaller/output_HaplotypeCaller

  output_SnpVQSR_recal_File:
    type: File
    outputSource: SnpVQSR/recal_File

  output_SnpVQSR_annotated_snps:
    type: File
    outputSource: SnpVQSR/annotated_snps

  output_IndelFilter_annotated_indels:
    type: File
    outputSource: IndelFilter/annotated_indels

steps:

  HaplotypeCaller:
    run: GATK-Sub-Workflow-Workflow-h3abionet-haplotype.cwl
    in:
      reference: reference
      uncompressed_reference: uncompressed_reference
      reads: reads
      bwa_output_name: bwa_output_name
      bwa_read_group: bwa_read_group
      bwa_threads: bwa_threads
      gatk_threads: gatk_threads
      samtools_threads: samtools_threads
      output_RefDictionaryFile: output_RefDictionaryFile
      samtools-view-isbam: samtools-view-isbam
      samtools-index-bai: samtools-index-bai
      output_samtools-view: output_samtools-view
      output_samtools-sort: output_samtools-sort
      outputFileName_MarkDuplicates: outputFileName_MarkDuplicates
      metricsFile_MarkDuplicates: metricsFile_MarkDuplicates
      readSorted_MarkDuplicates: readSorted_MarkDuplicates
      removeDuplicates_MarkDuplicates: removeDuplicates_MarkDuplicates
      createIndex_MarkDuplicates: createIndex_MarkDuplicates
      outputFileName_RealignTargetCreator: outputFileName_RealignTargetCreator
      known_variant_db: known_variant_db
      outputFileName_IndelRealigner: outputFileName_IndelRealigner
      outputFileName_BaseRecalibrator: outputFileName_BaseRecalibrator
      outputFileName_PrintReads: outputFileName_PrintReads
      outputFileName_HaplotypeCaller: outputFileName_HaplotypeCaller
      dbsnp: dbsnp
      tmpdir: tmpdir
      samtools-view-sambam: samtools-view-sambam
      covariate: covariate
      depth_omitIntervalStatistics: depth_omitIntervalStatistics
      depth_omitDepthOutputAtEachBase: depth_omitDepthOutputAtEachBase
      depth_outputfile_DepthOfCoverage: depth_outputfile_DepthOfCoverage
    out: [ output_bamstat, output_printReads, output_HaplotypeCaller ]

  SnpVQSR:
    run: GATK-Sub-Workflow-h3abionet-snp.cwl
    in:
      reference: reference
      snpf_genome: snpf_genome
      snpf_nodownload: snpf_nodownload
      snpf_data_dir: snpf_data_dir
      resource_mills: resource_mills
      haplotest_vcf: HaplotypeCaller/output_HaplotypeCaller
      resource_hapmap: resource_hapmap
      resource_omni: resource_omni
      resource_dbsnp: resource_dbsnp
    out: [ recal_File, annotated_snps ]

  IndelFilter:
    run: GATK-Sub-Workflow-h3abionet-indel-no-vqsr.cwl
    in:
      reference: reference
      snpf_genome: snpf_genome
      snpf_nodownload: snpf_nodownload
      snpf_data_dir: snpf_data_dir
      resource_mills: resource_mills
      haplotest_vcf: HaplotypeCaller/output_HaplotypeCaller
      resource_hapmap: resource_hapmap
      resource_omni: resource_omni
      resource_dbsnp: resource_dbsnp
      filter_expression: filter_expression
    out: [ annotated_indels ]
