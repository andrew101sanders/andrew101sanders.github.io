# Set the target width for resizing (adjust as needed)
$targetWidth = 800

# Get all PNG, JPG, and JPEG files in the current directory
$imageFiles = Get-ChildItem -Path . -Filter *.jpg -File

# Total number of files for progress tracking
$totalFiles = $imageFiles.Count
$currentFile = 0

foreach ($file in $imageFiles) {
    $currentFile++
    $percentComplete = [math]::Round(($currentFile / $totalFiles) * 100, 2)
    
    Write-Host "Processing file $currentFile of $totalFiles ($percentComplete%): $($file.Name)"
    
    # Get image dimensions
    $imageInfo = ffmpeg -i $file.FullName -v quiet -print_format json -show_format -show_streams | ConvertFrom-Json
    $width = $imageInfo.streams.width
    $height = $imageInfo.streams.height
    
    $outputFile = $file.DirectoryName + "\" + $file.BaseName + ".webp"
    
    # if ($width -gt $targetWidth) {
    #     # Resize and convert
    #     $newHeight = [math]::Round(($targetWidth / $width) * $height)
    #     ffmpeg -i $file.FullName -vf scale=$targetWidth:$newHeight $outputFile -y
    #     Write-Host "  Resized and converted to WebP: $($file.Name) -> $($file.BaseName).webp ($targetWidth x $newHeight)"
    # } else {
        # Convert without resizing
        ffmpeg -i $file.FullName $outputFile -y
        Write-Host "  Converted to WebP: $($file.Name) -> $($file.BaseName).webp ($width x $height)"
    # }
}

Write-Host "Conversion complete. Processed $totalFiles files."