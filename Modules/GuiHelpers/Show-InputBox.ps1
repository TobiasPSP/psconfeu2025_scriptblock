function Show-InputBox
{
    <#
            .SYNOPSIS
            Shows a GUI InputBox
            .DESCRIPTION
            Opens a fully customizable WPF-InputBox and returns the user input
            .EXAMPLE
            Show-InputBox -Prompt 'Enter Username' -Title 'Logon-Dialog' -Default $env:username -ButtonOkText 'Log On' -ButtonCancelText Cancel
            Displays a logon dialog and fills in the current user name as default text
            .EXAMPLE
            Show-KpmgInputBox -Prompt 'Enter your email address' -Title 'Mailbox' -ButtonOkText 'Retrieve Mail' -ButtonCancelText Cancel -Delegate { $_ -like '???*@???*.??*' }
            asks for an email address and uses a (very simple) email validator delegate so that the OK button will be enabled only after
            successful validation
    #>
    param
    (
        # Input Prompt
        [Parameter(Position=0)]
        [string]
        $Prompt = 'Your Input',
    
        # Window Title
        [string]
        $Title = 'PowerShell',
    
        # Default value for inputbox
        [string]
        $Default = '',
    
        # OK button text
        [string]
        $ButtonOkText = 'OK',
    
        # Cancel button text
        [string]
        $ButtonCancelText = 'Cancel',
    
        # PowerShell code to validate user input. Must evaluate to $true. $_ represents current user input:
        [ScriptBlock]
        $Delegate = { $true }
    )
  
    Add-Type -AssemblyName WindowsBase
    Add-Type -AssemblyName PresentationFramework
  
    # make scriptblock run in the correct thread
    $Delegate = [ScriptBlock]::Create($Delegate)

    #region XAML window definition
    # Right-click XAML and choose WPF/Edit... to edit WPF Design
    # in your favorite WPF editing tool
    $xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
Width="400"
MinWidth="200"
SizeToContent="Height"
WindowStartupLocation="CenterScreen"
Title=""
Topmost="True">
<Grid Margin="10,40,10,10">
<Grid.ColumnDefinitions>
<ColumnDefinition Width="*" />
<ColumnDefinition Width="Auto" />
</Grid.ColumnDefinitions>
<Grid.RowDefinitions>
<RowDefinition Height="Auto" />
<RowDefinition Height="Auto" />
<RowDefinition Height="Auto" />
<RowDefinition Height="*" />
</Grid.RowDefinitions>
<TextBlock Margin="5"
Name="txtPrompt"
Grid.Row="1">

</TextBlock>

<TextBox Name="TxtEingabe"
HorizontalAlignment="Stretch"
VerticalAlignment="Stretch"
Grid.Column="0"
Margin = "10"
Grid.ColumnSpan="2"
Grid.Row="3" />
<StackPanel
HorizontalAlignment="Right"
VerticalAlignment="Bottom"
Orientation="Horizontal"
Grid.ColumnSpan="2"
Margin = "10"
Grid.Row="3" />
<Button Name="ButOk"
HorizontalAlignment="Left"
VerticalAlignment="Top"
Grid.Column="1"
Margin = "0,0,10,0"
Width = "80"
Grid.Row="1">
OK
</Button>
<Button Name="ButCancel"
HorizontalAlignment="Left"
VerticalAlignment="Top"
Grid.Column="1"
Margin = "0,0,10,0"
Width = "80"
Grid.Row="2">
Cancel
</Button>
</Grid>
</Window>
'@
    #endregion
  
    #region Code Behind
    function Convert-XAMLtoWindow
    {
        param
        (
            [Parameter(Mandatory)]
            [string]
            $XAML
        )
      
      
      
        $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
        $result = [Windows.Markup.XAMLReader]::Load($reader)
        $reader.Close()
        $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
        while ($reader.Read())
        {
            $name=$reader.GetAttribute('Name')
            if (!$name) { $name=$reader.GetAttribute('x:Name') }
            if($name)
            {$result | Add-Member NoteProperty -Name $name -Value $result.FindName($name) -Force}
        }
        $reader.Close()
        $result
    }
    
    function Show-WPFWindow
    {
        param
        (
            [Parameter(Mandatory)]
            [Windows.Window]
            $Window
        )
      
        $result = $null
        $null = $window.Dispatcher.InvokeAsync{
            $result = $window.ShowDialog()
            Set-Variable -Name result -Value $result -Scope 1
        }.Wait()
        $result
    }
    #endregion Code Behind
  
    #region Convert XAML to Window
    $window = Convert-XAMLtoWindow -XAML $xaml 
    #endregion
  
  
  
    #region Define Event Handlers
    # Right-Click XAML Text and choose WPF/Attach Events to
    # add more handlers
    $window.ButCancel.add_Click(
        {
            $window.DialogResult = $false
        }
    )
    
    $window.ButOk.add_Click(
        {
            $window.DialogResult = $true
        }
    )
    $window.TxtEingabe.add_TextChanged{
        # remove param() block if access to event information is not required
        param
        (
            [Parameter(Mandatory)][Object]$sender,
            [Parameter(Mandatory)][Windows.Controls.TextChangedEventArgs]$e
        )
      
        ValidateInput
    }
    $window.txtEingabe.add_KeyDown{
        # remove param() block if access to event information is not required
        param
        (
            [Parameter(Mandatory)][Object]$sender,
            [Parameter(Mandatory)][Windows.Input.KeyEventArgs]$e
        )
        
        if ($e.Key -eq [System.Windows.Input.Key]::Enter)
        {
            $e.Handled = $true
            $window.DialogResult = $true
        }
        elseif ($e.Key -eq [System.Windows.Input.Key]::Escape)
        {
            $e.Handled = $true
            $window.txtEingabe.Text = ""
        }
    }
      
    
    
    function ValidateInput
    {
    

        $_ = $window.TxtEingabe.Text
        $window.ButOk.IsEnabled = & $Delegate
    }
        
      
      
      
    
    $window.Title = $Title
    $window.txtPrompt.Text = $Prompt
    $window.TxtEingabe.text = $Default
    $window.ButOk.Content = $ButtonOkText
    $window.ButCancel.Content = $ButtonCancelText
    
    ValidateInput
    
    $null = $window.TxtEingabe.Focus()
    
    #endregion Event Handlers
    
    #region Manipulate Window Content
  
    #endregion
    
    # Show Window
    $result = Show-WPFWindow -Window $window
  
    #region Process results
    if ($result -eq $true)
    {
        $window.TxtEingabe.Text
    }
    else
    {
        Write-Warning 'User aborted dialog.'
    }
    #endregion Process results
}