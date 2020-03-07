$object1 = Import-Excel C:\Users\cfg\Documents\lijst1.xlsx
$object2 = Import-Excel C:\Users\cfg\Documents\lijst2.xlsx
function reporton-compareobjectsproperties
{
param(
     $object1,
     $object2,
     $dataset_id,
     $anchorproperty
     )

$entries_removed_added = Compare-Object -ReferenceObject $object1 -DifferenceObject $object2 -Property $anchorproperty -IncludeEqual | select *, @{Name="RemovedOrAdded";Expression={if($_.sideindicator -eq "<="){"Removed"}elseif($_.sideindicator -eq "=="){"Same"}else{"Added"}}}
$properties = $object1 | gm -MemberType Properties | select -ExpandProperty Name 
foreach($entry in ($entries_removed_added | ? {$_.RemovedOrAdded -eq "Added"}))
{
$entry."$anchorproperty" + " has been " + $entry.RemovedOrAdded + " in dataset " + $($object2 | select -expand $dataset_id -Unique)
}

foreach($entry in ($entries_removed_added | ? {$_.RemovedOrAdded -eq "Removed"}))
{
$entry."$anchorproperty" + " has been " + $entry.RemovedOrAdded  + " in dataset " + $($object1 | select -expand $dataset_id -Unique)
}

foreach($entry in ($entries_removed_added | ? {$_.RemovedOrAdded -eq "Same"}))
{
    foreach($property in $properties)
    {
    if( $property -eq $dataset_id){}
    else
    {
        $comp = Compare-Object -ReferenceObject $($object1|?{$_." $anchorproperty" -eq $entry." $anchorproperty"}) -DifferenceObject $($object2|?{$_." $anchorproperty" -eq $entry." $anchorproperty"}) -Property $property 
        if($comp)
        {
            if($($object1|?{$_."$anchorproperty" -eq $entry."$anchorproperty"})."$property".tostring() -eq $($object2|?{$_."$anchorproperty" -eq $entry."$anchorproperty"})."$property".tostring())
            {}
            else
            {
            $entry."$anchorproperty".tostring()+`
            " with "+`
            $property.tostring()+`
            " was "+`
            $($object1|?{$_."$anchorproperty" -eq $entry."$anchorproperty"})."$property".tostring()+`
            " in dataset "+`
            $($object1 | select -expand $dataset_id -Unique).tostring()+`
            " is now "+`
            $($object2|?{$_."$anchorproperty" -eq $entry."$anchorproperty"})."$property".tostring()+`
            " in dataset "+`
            $($object2 | select -expand $dataset_id -Unique).tostring()
            }
        }
    }
}

}
}
Analyse-objectsproperties -object1 $object1 -object2 $object2 -anchorproperty Eigenschap_1 -dataset_id scandate