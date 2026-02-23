param($path)
(Get-Content $path) -replace '^pick 6ed8e37', 'edit 6ed8e37' | Set-Content $path
