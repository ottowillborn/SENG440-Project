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
$remoteAsmFile = "$remoteDir/main.s"
$localAsmFile = "$localDir/main.s"

# === Upload specific files ===
Write-Host "Copying audio_sample.wav, main.c, and readme.md to VM..."
scp -P $remotePort audio_sample.wav main.c readme.md "${remoteUser}@${remoteHost}:$remoteDir"

# === Build, generate assembly, and run remotely ===
Write-Host "Building and running inside VM..."
ssh -p $remotePort "${remoteUser}@${remoteHost}" "cd $remoteDir && gcc -O2 -Wall main.c -o main.out && gcc -O2 -S main.c -o main.s && ./main.out"

# === Download output files ===
Write-Host "Downloading compressed_output.ulaw back to local machine..."
scp -P $remotePort "${remoteUser}@${remoteHost}:$remoteCompressedOutputFile" "$localCompressedOutputFile"
Write-Host "Downloading decompressed.pcm back to local machine..."
scp -P $remotePort "${remoteUser}@${remoteHost}:$remoteDecompressedPCMFile" "$localDecompressedPCMFile"

# === Download generated assembly ===
Write-Host "Downloading generated assembly (main.s)..."
scp -P $remotePort "${remoteUser}@${remoteHost}:$remoteAsmFile" "$localAsmFile"

Write-Host "Done."