[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
                        -ChildPath "..\..\Unit" `
                        -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
            -ChildPath "\Stubs\Microsoft365.psm1" `
            -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
    -ChildPath "\Stubs\Generic.psm1" `
    -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath "\UnitTestHelper.psm1" `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource "AADMSGroupLifecyclePolicy" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString "test@password1" -AsPlainText -Force
            $GlobalAdminAccount = New-Object System.Management.Automation.PSCredential ("tenantadmin", $secpasswd)

            Mock -CommandName Get-M365DSCExportContentForResource -MockWith {

            }

            Mock -CommandName Get-PSSession -MockWith {

            }

            Mock -CommandName Remove-PSSession -MockWith {

            }

            Mock -CommandName Set-AzureADMSGroupLifecyclePolicy -MockWith {

            }

            Mock -CommandName Remove-AzureADMSGroupLifecyclePolicy -MockWith {

            }

            Mock -CommandName New-AzureADMSGroupLifecyclePolicy -MockWith {

            }
        }

        # Test contexts
        Context -Name "The Policy should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AlternateNotificationEmails = @("john.smith@contoso.com");
                    Ensure                      = "Present";
                    GlobalAdminAccount          = $GlobalAdminAccount;
                    GroupLifetimeInDays         = 99;
                    IsSingleInstance            = "Yes";
                    ManagedGroupTypes           = "Selected";
                }

                Mock -CommandName New-M365DSCConnection -MockWith {
                    return "Credential"
                }

                Mock -CommandName Get-AzureADMSGroupLifecyclePolicy -MockWith {
                    return $null
                }
            }

            It "Should return Values from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName "Get-AzureADMSGroupLifecyclePolicy" -Exactly 1
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }
            $Script:calledOnceAlready = $false
            It 'Should Create the Policy from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName "New-AzureADMSGroupLifecyclePolicy" -Exactly 1
                Should -Invoke -CommandName "Set-AzureADMSGroupLifecyclePolicy" -Exactly 0
                Should -Invoke -CommandName "Remove-AzureADMSGroupLifecyclePolicy" -Exactly 0
            }
        }

        Context -Name "The Policy exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AlternateNotificationEmails = @("john.smith@contoso.com", 'bob.houle@contoso.com');
                    Ensure                      = "Absent";
                    GlobalAdminAccount          = $GlobalAdminAccount;
                    GroupLifetimeInDays         = 99;
                    IsSingleInstance            = "Yes";
                    ManagedGroupTypes           = "Selected";
                }

                Mock -CommandName New-M365DSCConnection -MockWith {
                    return "Credential"
                }

                Mock -CommandName Get-AzureADMSGroupLifecyclePolicy -MockWith {
                    return @{
                        AlternateNotificationEmails = @("john.smith@contoso.com", 'bob.houle@contoso.com');
                        GroupLifetimeInDays         = 99;
                        ManagedGroupTypes           = "Selected";
                        Id                          = '12345-12345-12345-12345-12345'
                    }
                }
            }

            It "Should return Values from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
                Should -Invoke  -CommandName "Get-AzureADMSGroupLifecyclePolicy" -Exactly 1
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should Remove the Policy from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName "New-AzureADMSGroupLifecyclePolicy" -Exactly 0
                Should -Invoke -CommandName "Set-AzureADMSGroupLifecyclePolicy" -Exactly 0
                Should -Invoke -CommandName "Remove-AzureADMSGroupLifecyclePolicy" -Exactly 1
            }
        }

        Context -Name "The Policy Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AlternateNotificationEmails = @("john.smith@contoso.com", 'bob.houle@contoso.com');
                    Ensure                      = "Present";
                    GlobalAdminAccount          = $GlobalAdminAccount;
                    GroupLifetimeInDays         = 99;
                    IsSingleInstance            = "Yes";
                    ManagedGroupTypes           = "Selected";
                }

                Mock -CommandName New-M365DSCConnection -MockWith {
                    return "Credential"
                }

                Mock -CommandName Get-AzureADMSGroupLifecyclePolicy -MockWith {
                    return @{
                        AlternateNotificationEmails = @("john.smith@contoso.com", 'bob.houle@contoso.com');
                        GroupLifetimeInDays         = 99;
                        ManagedGroupTypes           = "Selected";
                        Id                          = '12345-12345-12345-12345-12345'
                    }
                }
            }

            It "Should return Values from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName "Get-AzureADMSGroupLifecyclePolicy" -Exactly 1
            }

            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name "Values are NOT in the desired state" -Fixture {
            BeforeAll{
                $testParams = @{
                    AlternateNotificationEmails = @("john.smith@contoso.com", 'bob.houle@contoso.com');
                    Ensure                      = "Present";
                    GlobalAdminAccount          = $GlobalAdminAccount;
                    GroupLifetimeInDays         = 77; #Drift
                    IsSingleInstance            = "Yes";
                    ManagedGroupTypes           = "Selected";
                }

                Mock -CommandName New-M365DSCConnection -MockWith {
                    return "Credential"
                }

                Mock -CommandName Get-AzureADMSGroupLifecyclePolicy -MockWith {
                    return @{
                        AlternateNotificationEmails = @("john.smith@contoso.com", 'bob.houle@contoso.com');
                        GroupLifetimeInDays         = 99;
                        ManagedGroupTypes           = "Selected";
                        Id                          = '12345-12345-12345-12345-12345'
                    }
                }
            }

            It "Should return Values from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName "Get-AzureADMSGroupLifecyclePolicy" -Exactly 1
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should Update the Policy from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName "New-AzureADMSGroupLifecyclePolicy" -Exactly 0
                Should -Invoke -CommandName "Set-AzureADMSGroupLifecyclePolicy" -Exactly 1
                Should -Invoke -CommandName "Remove-AzureADMSGroupLifecyclePolicy" -Exactly 0
            }
        }

        Context -Name "ReverseDSC Tests" -Fixture {
            BeforeAll {
                $testParams = @{
                    GlobalAdminAccount = $GlobalAdminAccount
                }

                Mock -CommandName New-M365DSCConnection -MockWith {
                    return "Credential"
                }

                Mock -CommandName Get-AzureADMSGroupLifecyclePolicy -MockWith {
                    return @{
                        AlternateNotificationEmails = @("john.smith@contoso.com", 'bob.houle@contoso.com');
                        GroupLifetimeInDays         = 99;
                        ManagedGroupTypes           = "Selected";
                        Id                          = '12345-12345-12345-12345-12345'
                    }
                }
            }

            It "Should Reverse Engineer resource from the Export method" {
                Export-TargetResource @testParams
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
