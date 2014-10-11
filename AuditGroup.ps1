Get-ADGroupMember 'Domain Admins'| FT name > 'c:\temp\DOMAdmin.txt'
 
$added = Compare-Object -ReferenceObject $( Get-Content 'c:\temp\DOMAdmin_Base.txt') -DifferenceObject $( Get-Content 'c:\temp\DOMAdmin.txt') |
where-Object {$_.Sideindicator -eq '=>'} | Ft -HideTableHeaders InputObject
 
 
$removed = Compare-Object -ReferenceObject $( Get-Content 'c:\temp\DOMAdmin_Base.txt') -DifferenceObject $( Get-Content 'c:\temp\DOMAdmin.txt') |
where-Object {$_.Sideindicator -eq '<='} | FT -HideTableHeaders InputObject
 
$added = $added | Out-String
$removed = $removed | Out-String
 
If ((($added).Length) -eq 0 -and (($removed).Length) -eq 0) {
    Write-EventLog -LogName Application -Source "Lumic"  -EntryType Information -EventId 696 -Message 'Domain Admins: No Changes Detected in Group Memembership'
    Exit
}
Else {
Write-EventLog -LogName Application -Source "Lumic"  -EntryType Information -EventId 696 -Message "Domain Admins: Changes Detected in Group Memembership: Users added: $added. Users Removed $removed"
Remove-item 'c:\temp\DOMAdmin_Base.txt' -force
Rename-item 'c:\temp\DOMAdmin.txt' -NewName 'DOMAdmin_Base.txt'

$body = "Users added to Group $added Users removed from Group $removed"   
 $emailinfo = @{                        
                Subject = "Domain Admin Auditing"                        
                Body = $body | Out-String    
                From = "audit@domain.co.uk"                        
                To =  "Emailaddress"                        
                SmtpServer = "SMTPServer"                     
            }                        
         Send-MailMessage @emailinfo
} 
