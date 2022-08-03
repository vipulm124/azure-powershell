$StorageAccountName = "straccountvipul"
$Key = "INSERT YOUR STORAGE KEY HERE"
$Container1 = "containera"
$container2 = "containerb"
$StorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $Key


<# Get all blobs from the container #>
$blobs = Get-AzStorageBlob -Container $Container1 -Context $StorageContext

$LocalFolderPath = "C:\test\Files"

<# Empty the local folder before starting the process#>
Get-ChildItem -Path $LocalFolderPath -Include *.* -File -Recurse | foreach { $_.Delete()}

foreach ($blob in $blobs)
{

<# Process only txt file #>
if($blob.name.contains('.txt'))
{
$FilePath = $blob.name -replace '/','\'

<# Download blob to your local folder #>
Get-AzStorageBlobContent -Container $Container1 -Blob $FilePath -Destination $LocalFolderPath -Context $StorageContext

<# Get content of the current blobl file #>
$contentOfFile = Get-Content "$($LocalFolderPath)\$($FilePath)"

<# Update the content #>
$contentOfFile = "Appending Text of the file. " + $contentOfFile;

<# Update the file with the new content #>
Set-Content -Path "$($LocalFolderPath)\$($FilePath)" -Value $contentOfFile

<# Upload the updated blob file to another container #>
Set-AzStorageBlobContent -File "$($LocalFolderPath)\$($FilePath)" -Container $container2 -Blob $FilePath -Context $StorageContext -StandardBlobTier 'Hot'

<# Delet the processed file from local so as to save space and time #>
Remove-Item "$($LocalFolderPath)\$($FilePath)"

}
}