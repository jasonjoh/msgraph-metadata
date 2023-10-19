param(
    [Parameter(Mandatory=$true)][string]$repoDirectory
)

$transformCsdlDirectory = Join-Path $repoDirectory "transforms/csdl"
$transformScript = Join-Path $transformCsdlDirectory "transform.ps1"
$xsltPath = Join-Path $transformCsdlDirectory "preprocess_csdl.xsl"
$conversionSettingsDirectory = Join-Path $repoDirectory "conversion-settings"
$schemaDirectory = Join-Path $repoDirectory "schemas"

$metaDataFiles = "v1.0-Fairfax", "v1.0-Mooncake", "v1.0-Prod"
$metaDataBetaFiles = "beta-Fairfax", "beta-Mooncake", "beta-Prod"

foreach($file in $metaDataFiles)
{
    $csdl = "$($file).csdl"
    $csdlPath = Join-Path $schemaDirectory $csdl
    $transform = Join-Path $repoDirectory "transformed_$($csdl)"
    $fileParts = $file -split "-"
    $openapiFile = $fileParts[1]
    $openapi = Join-Path $repoDirectory "schemas/openapi/v1.0/$($openapiFile).yml"
    $version = "v1.0"

    Write-Host "Tranforming $csdl metadata using xslt with parameters used in the OpenAPI flow..." -ForegroundColor Green
    & $transformScript -xslPath $xsltPath -inputPath $csdlPath -outputPath $transform -addInnerErrorDescription $true -removeCapabilityAnnotations $false -csdlVersion $version

    Write-Host "Converting $transform metadata to OpenAPI..." -ForegroundColor Green
    & hidi transform --cs $transform -o $openapi --co -f Yaml --sp "$conversionSettingsDirectory/openapi.json"
}

foreach($file in $metaDataBetaFiles)
{
    $csdl = "$($file).csdl"
    $csdlPath = Join-Path $schemaDirectory $csdl
    $transform = Join-Path $repoDirectory "transformed_$($csdl)"
    $fileParts = $file -split "-"
    $openapiFile = $fileParts[1]
    $openapi = Join-Path $repoDirectory "schemas/openapi/beta/$($openapiFile).yml"
    $version = "beta"

    Write-Host "Tranforming $csdl metadata using xslt with parameters used in the OpenAPI flow..." -ForegroundColor Green
    & $transformScript -xslPath $xsltPath -inputPath $csdlPath -outputPath $transform -addInnerErrorDescription $true -removeCapabilityAnnotations $false -csdlVersion $version

    Write-Host "Converting $transform metadata to OpenAPI..." -ForegroundColor Green
    & hidi transform --cs $transform -o $openapi --co -f Yaml --sp "$conversionSettingsDirectory/openapi.json"
}
