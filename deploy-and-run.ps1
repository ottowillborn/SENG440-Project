# === Config ===
$remotePort = 2222
$remoteUser = "root"
$remoteHost = "localhost"
$localDir = "."
$remoteDir = "/root/audioCompression"
$remoteCompressedOutputFile = "$remoteDir/compressed_output.ulaw"
$localCompressedOutputFile = "$localDir/compressed_output.ulaw"
$remoteDecompressedPCMFile = "$remoteDir/decompressed.pcm"
$localDecompressedPCMFile = "$localDir/decompressed.pcm"

# === Upload code ===
Write-Host "Copying code to VM..."
scp -P $remotePort -r $localDir "${remoteUser}@${remoteHost}:$remoteDir"

# === Build and run remotely ===
Write-Host "Running build inside VM..."
ssh -p $remotePort "${remoteUser}@${remoteHost}" "cd $remoteDir && gcc main.c -o main.out && ./main.out"

# === Download output file ===
Write-Host "Downloading compressed_output.ulaw back to local machine..."
scp -P $remotePort "${remoteUser}@${remoteHost}:$remoteCompressedOutputFile" "$localCompressedOutputFile"
Write-Host "Downloading decompressed.pcm back to local machine..."
scp -P $remotePort "${remoteUser}@${remoteHost}:$remoteDecompressedPCMFile" "$localDecompressedPCMFile"

Write-Host "Done."