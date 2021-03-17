param($root, $projectlocation)

# script modified, original was found on https://stackoverflow.com/questions/41467988/how-to-get-list-of-packages-of-a-particular-visual-studio-solution-with-nuget-ex
#This will be the root folder of all your solutions - we will search all  children of this folder
$SOLUTIONROOT = $root
[System.Collections.ArrayList]$packageslist = @();

Function ListAllPackages ($BaseDirectory)
{
    Write-Host "Starting Package List - This may take a few minutes ..."
    $PACKAGECONFIGS = Get-ChildItem -Recurse -Force $BaseDirectory -ErrorAction SilentlyContinue | 
        Where-Object { ($_.PSIsContainer -eq $false) -and  ( $_.Name -eq "packages.config")}
        
    ForEach($PACKAGECONFIG in $PACKAGECONFIGS)
        {
            $path = $PACKAGECONFIG.FullName
            
            $xml = [xml]$packages = Get-Content $path
            
                            foreach($package in $packages.packages.package)
                            {
                                if($package.developmentDependency -ne "true") {
                                     $entry = "<PackageReference Include=`"$($package.id)`" Version=`"$($package.version)`" Framework=`"$($package.targetFramework)`" />"
                                     $packageslist.Add($entry)
                                    
                                 }
                             }

        }
}

Function CreateProjectFile ($projectlocation)
{
    $uniqueList = $packageslist | Sort-Object  | Get-Unique

    $start = '<Project Sdk="Microsoft.NET.Sdk.Web">

      <PropertyGroup>
        <TargetFramework>net48</TargetFramework>
      </PropertyGroup>

      <ItemGroup>'

      $end = "</ItemGroup>

    </Project>"

$total = $start + $uniqueList + $end
$total | Out-File $projectlocation
    
}

ListAllPackages $SOLUTIONROOT
CreateProjectFile $projectlocation



