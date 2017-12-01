library("seqCAT")
context("Creation of SNV profiles")

# Path
file1 <- system.file("extdata", "test.vcf.gz", package = "seqCAT")
file2 <- system.file("extdata", "test.unannotated.vcf.gz", package = "seqCAT")

# Extract variants
suppressMessages(create_profile(vcf_file     = file1,
                                sample       = "sample1",
                                output_file  = "profile_1.txt",
                                filter_depth = 10,
                                python       = FALSE))

suppressMessages(create_profile(vcf_file     = file1,
                                sample       = "sample2",
                                output_file  = "profile_2.txt",
                                filter_depth = 10,
                                python       = FALSE))

suppressMessages(create_profile(vcf_file     = file2,
                                sample       = "sample3",
                                output_file  = "profile_3.txt",
                                filter_depth = 10,
                                python       = FALSE))

# Read profiles
profile_1 <- read.table(file             = "profile_1.txt",
                        sep              = "\t",
                        header           = TRUE,
                        stringsAsFactors = FALSE)

profile_2 <- read.table(file             = "profile_2.txt",
                        sep              = "\t",
                        header           = TRUE,
                        stringsAsFactors = FALSE)

profile_3 <- read.table(file             = "profile_3.txt",
                        sep              = "\t",
                        header           = TRUE,
                        stringsAsFactors = FALSE)

# Remove files
file.remove("profile_1.txt")
file.remove("profile_2.txt")
file.remove("profile_3.txt")

# Tests
test_that("extract_variants yields correct dimensions", {
    expect_equal(dim(profile_1), c(428, 18))
    expect_equal(dim(profile_2), c(428, 18))
})

test_that("only variants passing the depth threshold are extracted", {
    expect_equal(nrow(profile_1[profile_1$DP == 0, ]), 0)
    expect_equal(nrow(profile_2[profile_2$DP == 0, ]), 0)
})

test_that("no indels are extracted", {
    expect_equal(nrow(profile_1[nchar(profile_1$REF) != 1, ]), 0)
    expect_equal(nrow(profile_1[nchar(profile_1$ALT) != 1, ]), 0)
    expect_equal(nrow(profile_2[nchar(profile_2$REF) != 1, ]), 0)
    expect_equal(nrow(profile_2[nchar(profile_2$ALT) != 1, ]), 0)
})

test_that("the MT chromosome only exists in sample 1", {
    expect_equal(nrow(profile_1[profile_1$chr == "MT", ]), 1)
    expect_equal(nrow(profile_2[profile_2$chr == "MT", ]), 0)
})

test_that("the correct variants across impact categories are extracted", {
    expect_equal(nrow(profile_1[profile_1$impact == "HIGH", ]), 1)
    expect_equal(nrow(profile_2[profile_2$impact == "HIGH", ]), 0)
    expect_equal(nrow(profile_1[profile_1$impact == "MODERATE", ]), 4)
    expect_equal(nrow(profile_2[profile_2$impact == "MODERATE", ]), 4)
    expect_equal(nrow(profile_1[profile_1$impact == "LOW", ]), 0)
    expect_equal(nrow(profile_2[profile_2$impact == "LOW", ]), 0)
    expect_equal(nrow(profile_1[profile_1$impact == "MODIFIER", ]), 423)
    expect_equal(nrow(profile_2[profile_2$impact == "MODIFIER", ]), 424)
})

test_that("empty calls from multi-sample VCFs are handled correctly", {
    expect_equal(nrow(profile_1[profile_1$rsID == "rs182017058", ]), 0)
    expect_equal(nrow(profile_2[profile_2$rsID == "rs182017058", ]), 3)
})

test_that("VCFs without variant annotations are handled correctly", {
    expect_equal(nrow(profile_3), 99)
})