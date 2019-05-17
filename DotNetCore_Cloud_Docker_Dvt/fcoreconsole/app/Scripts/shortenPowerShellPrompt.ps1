function prompt {
  $p = Split-Path -leaf -path (Get-Location)
  "PS $p> "
}