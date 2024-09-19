# Set the target widths for resizing
$targetWidths = @(320, 640, 1280)

# Get all PNG and JPG files in the current directory
$imageFiles = Get-ChildItem -Path . -Include *.png, *.jpg -File

# Total number of files for progress tracking
$totalFiles = $imageFiles.Count
$currentFile = 0

foreach ($file in $imageFiles) {
    $currentFile++
    $percentComplete = [math]::Round(($currentFile / $totalFiles) * 100, 2)
    
    Write-Host "Processing file $currentFile of $totalFiles ($percentComplete%): $($file.Name)"
    
    # Get image dimensions
    $imageInfo = ffmpeg -i $file.FullName -v quiet -print_format json -show_format -show_streams | ConvertFrom-Json
    $originalWidth = $imageInfo.streams.width
    $originalHeight = $imageInfo.streams.height
    
    foreach ($targetWidth in $targetWidths) {
        if ($originalWidth -gt $targetWidth) {
            $newHeight = [math]::Round(($targetWidth / $originalWidth) * $originalHeight)
            
            # Create WebP version
            $outputFileWebP = $file.DirectoryName + "\" + $file.BaseName + "_" + $targetWidth + "w.webp"
            ffmpeg -i $file.FullName -vf scale=$targetWidth:$newHeight $outputFileWebP -y
            
            # Create PNG version
            $outputFilePNG = $file.DirectoryName + "\" + $file.BaseName + "_" + $targetWidth + "w.png"
            ffmpeg -i $file.FullName -vf scale=$targetWidth:$newHeight $outputFilePNG -y
            
            Write-Host "  Resized and converted: $($file.Name) -> ${targetWidth}w (WebP and PNG)"
        }
    }
    
    # Always create a WebP version at original size
    $outputFileWebP = $file.DirectoryName + "\" + $file.BaseName + "_original.webp"
    ffmpeg -i $file.FullName $outputFileWebP -y
    
    Write-Host "  Converted to WebP (original size): $($file.Name) -> $($file.BaseName)_original.webp"
}

Write-Host "Conversion complete. Processed $totalFiles files."