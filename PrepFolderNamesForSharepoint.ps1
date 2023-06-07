#During Sharepoint upload, this message may occur:
#Scan File Failure:Path contains invalid characters. Valid path doesn't start or end with space. Other invalid characters are <, ?, >, *, |, ", :, \, /

#To resolve: 

$rootPath = "\\your\networkpath"

function Fix-FolderNames($path) {
    $folders = Get-ChildItem -LiteralPath $path -Recurse -Directory

    foreach ($folder in $folders) {
        $originalPath = $folder.FullName + "\"
        $newFolderName = $folder.FullName.Trim(" <>?*|`":")
        $newFolderSplit = $newFolderName | Split-Path -Leaf

        $alreadyExists = Test-Path $newFolderName

        if ($folder.FullName -ne $newFolderName) {
            if ($alreadyExists -ne $True) {
                Rename-Item $originalPath $newFolderSplit -Confirm
                Write-Host "Renamed folder: '$($folder.Name)' to '$newFolderName'"
                    }
            else {
                $copyof = $newFolderSplit + "_copy"
                Rename-Item $originalPath $copyof -Confirm
                Write-Host "Renamed folder: '$($folder.Name)' to '$newFolderName'"
            }
    }
} }

$parent_paths = (Get-ChildItem -LiteralPath $rootPath -Directory).FullName
    foreach ($parent in $parent_paths) {
    Fix-FolderNames -path $parent
    }