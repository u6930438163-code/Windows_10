#Requires -Version 5.1
<#
.SYNOPSIS
  Pełnoekranowy pulpit dotykowy Windows_10 (WPF), obsługiwany także myszą.
.DESCRIPTION
  To nakładka uruchamiana jako zwykły użytkownik; nie zastępuje explorer.exe.
  Do rzeczywistego dotyku potrzebny jest ekran dotykowy albo poprawne przekazywanie dotyku.
.EXAMPLE
  powershell.exe -NoProfile -STA -File .\ui\TouchShell.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
if ($env:OS -ne "Windows_NT") { throw "To narzędzie wymaga systemu Windows." }
if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne "STA") {
    throw "Uruchom PowerShell w STA: powershell.exe -NoProfile -STA -File .\ui\TouchShell.ps1"
}
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

[xml]$layout = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Windows_10 • Pulpit dotykowy" Width="1050" Height="720"
        MinWidth="360" MinHeight="520" WindowStartupLocation="CenterScreen"
        WindowState="Maximized" ShowInTaskbar="True"
        FontFamily="Segoe UI" Background="#0B1220" Foreground="#EFF6FF">
  <Window.Resources>
    <Style x:Key="TouchButton" TargetType="Button">
      <Setter Property="MinWidth" Value="190" />
      <Setter Property="MinHeight" Value="86" />
      <Setter Property="Margin" Value="6" />
      <Setter Property="Padding" Value="12" />
      <Setter Property="FontSize" Value="19" />
      <Setter Property="FontWeight" Value="SemiBold" />
      <Setter Property="Foreground" Value="#F9FAFB" />
      <Setter Property="Background" Value="#19314D" />
      <Setter Property="BorderBrush" Value="#426683" />
      <Setter Property="BorderThickness" Value="1" />
      <Setter Property="Cursor" Value="Hand" />
    </Style>
    <Style x:Key="ActionButton" TargetType="Button" BasedOn="{StaticResource TouchButton}">
      <Setter Property="MinWidth" Value="125" />
      <Setter Property="MinHeight" Value="62" />
      <Setter Property="FontSize" Value="17" />
      <Setter Property="Background" Value="#17669C" />
    </Style>
  </Window.Resources>
  <Grid Margin="16">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto" />
      <RowDefinition Height="*" />
      <RowDefinition Height="Auto" />
    </Grid.RowDefinitions>
    <DockPanel Grid.Row="0" Margin="6,4,6,16" LastChildFill="False">
      <StackPanel DockPanel.Dock="Left">
        <TextBlock Text="WINDOWS_10" FontWeight="Bold" FontSize="28" />
        <TextBlock Text="Pulpit dotykowy • Alex • Aria • Astyria • Aurelius"
                   Foreground="#9DC5E8" FontSize="15" TextWrapping="Wrap" />
      </StackPanel>
      <Button x:Name="CloseButton" DockPanel.Dock="Right"
              Style="{StaticResource ActionButton}" Content="Zamknij nakładkę" />
      <Button x:Name="MinimizeButton" DockPanel.Dock="Right"
              Style="{StaticResource ActionButton}" Content="Pokaż pulpit" />
    </DockPanel>

    <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto"
                  HorizontalScrollBarVisibility="Disabled" PanningMode="VerticalOnly">
      <StackPanel>
        <TextBlock Text="SYSTEM" FontSize="17" FontWeight="Bold" Foreground="#9DC5E8" Margin="7,0,0,8" />
        <WrapPanel>
          <Button x:Name="FilesButton" Style="{StaticResource TouchButton}" Content="Pliki" />
          <Button x:Name="SettingsButton" Style="{StaticResource TouchButton}" Content="Ustawienia" />
          <Button x:Name="KeyboardButton" Style="{StaticResource TouchButton}" Content="Klawiatura ekranowa" />
          <Button x:Name="TouchSettingsButton" Style="{StaticResource TouchButton}" Content="Ustawienia dotyku" />
          <Button x:Name="TabletButton" Style="{StaticResource TouchButton}" Content="Tryb tabletu" />
          <Button x:Name="StartButton" Style="{StaticResource TouchButton}" Content="Menu Start" />
          <Button x:Name="TaskManagerButton" Style="{StaticResource TouchButton}" Content="Menedżer zadań" />
          <Button x:Name="TerminalButton" Style="{StaticResource TouchButton}" Content="PowerShell" />
          <Button x:Name="DisplayButton" Style="{StaticResource TouchButton}" Content="Ekran i skala" />
        </WrapPanel>
        <TextBlock Text="OPENAI" FontSize="17" FontWeight="Bold" Foreground="#9DC5E8" Margin="7,18,0,8" />
        <WrapPanel>
          <Button x:Name="ChatGPTButton" Style="{StaticResource TouchButton}" Content="ChatGPT" />
          <Button x:Name="CodexButton" Style="{StaticResource TouchButton}" Content="Codex" />
          <Button x:Name="BrowserButton" Style="{StaticResource TouchButton}" Content="Przeglądarka" />
        </WrapPanel>
        <TextBlock Text="AGENTY AI — WIADOMOŚCI" FontSize="17" FontWeight="Bold"
                   Foreground="#9DC5E8" Margin="7,20,0,8" />
        <StackPanel Margin="6,0,6,0">
          <TextBlock Text="Adresat" FontSize="16" />
          <ComboBox x:Name="AgentSelector" FontSize="20" Height="55"
                    Background="#F1F5F9" Foreground="#15263E" SelectedIndex="0">
            <ComboBoxItem Content="Alex" />
            <ComboBoxItem Content="Aria" />
            <ComboBoxItem Content="Astyria" />
            <ComboBoxItem Content="Aurelius" />
            <ComboBoxItem Content="all" />
          </ComboBox>
          <TextBlock Text="Wiadomość" FontSize="16" Margin="0,14,0,0" />
          <TextBox x:Name="MessageBox" Height="105" FontSize="19" TextWrapping="Wrap"
                   AcceptsReturn="True" VerticalScrollBarVisibility="Auto"
                   Foreground="#111827" Background="#FFFFFF" Padding="10" />
          <WrapPanel Margin="0,8,0,0">
            <Button x:Name="SendButton" Style="{StaticResource ActionButton}" Content="Wyślij" />
            <Button x:Name="StatusButton" Style="{StaticResource ActionButton}" Content="Status agentów" />
            <Button x:Name="InboxButton" Style="{StaticResource ActionButton}" Content="Odpowiedzi" />
          </WrapPanel>
          <TextBlock Text="Ostatni wynik / odebrane wiadomości" FontSize="15" Margin="0,12,0,4" />
          <TextBox x:Name="OutputBox" MinHeight="145" MaxHeight="320"
                   IsReadOnly="True" FontFamily="Consolas" FontSize="15"
                   TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"
                   Foreground="#E4F3FE" Background="#152338" Padding="10" />
        </StackPanel>
      </StackPanel>
    </ScrollViewer>
    <TextBlock x:Name="BottomStatus" Grid.Row="2" Margin="8,12,8,4"
               TextWrapping="Wrap" FontSize="14" Foreground="#A6D0E9"
               Text="Nakładka dotykowa; wszystkie funkcje Windows poza panelem pozostają bez zmian." />
  </Grid>
</Window>
'@

$reader = [System.Xml.XmlNodeReader]::new($layout)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

function Get-UIElement([string]$Name) {
    $item = $window.FindName($Name)
    if ($null -eq $item) { throw "Nie znaleziono elementu: $Name" }
    return $item
}
function Launch([string]$Target, [string]$Arguments = "") {
    try {
        if ($Arguments) { Start-Process -FilePath $Target -ArgumentList $Arguments | Out-Null }
        else { Start-Process -FilePath $Target | Out-Null }
    } catch {
        (Get-UIElement "BottomStatus").Text = "Błąd otwierania aplikacji: $($_.Exception.Message)"
    }
}
function AgentRequest([string]$Method, [string]$Endpoint, [object]$Payload = $null) {
    $token = [Environment]::GetEnvironmentVariable("WINDOWS10_LOCAL_TOKEN", "Process")
    if ([string]::IsNullOrWhiteSpace($token)) {
        throw "Brak WINDOWS10_LOCAL_TOKEN. Uruchom lokalny serwer agentów zgodnie z ui/README.md."
    }
    $params = @{
        Uri = "http://127.0.0.1:8765$Endpoint"
        Method = $Method
        Headers = @{ Authorization = "Bearer $token" }
        TimeoutSec = 12
    }
    if ($null -ne $Payload) {
        $params.ContentType = "application/json; charset=utf-8"
        $params.Body = ConvertTo-Json -InputObject $Payload -Depth 6
    }
    Invoke-RestMethod @params
}
function ShowResult([object]$Result) {
    (Get-UIElement "OutputBox").Text = (ConvertTo-Json -InputObject $Result -Depth 7)
}
(Get-UIElement "CloseButton").Add_Click({ $window.Close() })
(Get-UIElement "MinimizeButton").Add_Click({ $window.WindowState = "Minimized" })
(Get-UIElement "FilesButton").Add_Click({ Launch "explorer.exe" })
(Get-UIElement "SettingsButton").Add_Click({ Launch "explorer.exe" "ms-settings:" })
(Get-UIElement "TouchSettingsButton").Add_Click({ Launch "explorer.exe" "ms-settings:devices-touch" })
(Get-UIElement "TabletButton").Add_Click({ Launch "explorer.exe" "ms-settings:tabletmode" })
(Get-UIElement "DisplayButton").Add_Click({ Launch "explorer.exe" "ms-settings:display" })
(Get-UIElement "StartButton").Add_Click({
    # Nie wstrzykujemy syntetycznych klawiszy; otwieramy systemowy folder aplikacji Start.
    Launch "explorer.exe" "shell:AppsFolder"
})
(Get-UIElement "TaskManagerButton").Add_Click({ Launch "taskmgr.exe" })
(Get-UIElement "TerminalButton").Add_Click({ Launch "powershell.exe" "-NoExit -NoProfile" })
(Get-UIElement "KeyboardButton").Add_Click({
    $touchKeyboard = Join-Path $env:CommonProgramFiles "microsoft shared\ink\TabTip.exe"
    if (Test-Path -LiteralPath $touchKeyboard) { Launch $touchKeyboard }
    else { Launch "osk.exe" }
})
(Get-UIElement "ChatGPTButton").Add_Click({ Launch "https://chatgpt.com" })
(Get-UIElement "CodexButton").Add_Click({ Launch "https://developers.openai.com/codex/" })
(Get-UIElement "BrowserButton").Add_Click({ Launch "https://www.microsoft.com" })
(Get-UIElement "StatusButton").Add_Click({
    try { ShowResult (AgentRequest "GET" "/v1/agents") }
    catch { (Get-UIElement "OutputBox").Text = $_.Exception.Message }
})
(Get-UIElement "InboxButton").Add_Click({
    try { ShowResult (AgentRequest "GET" "/v1/inbox?recipient=user") }
    catch { (Get-UIElement "OutputBox").Text = $_.Exception.Message }
})
(Get-UIElement "SendButton").Add_Click({
    try {
        $selection = (Get-UIElement "AgentSelector").SelectedItem
        $to = [string]$selection.Content
        $message = (Get-UIElement "MessageBox").Text.Trim()
        if (-not $message) { throw "Wpisz wiadomość." }
        if ($message.Length -gt 4000) { throw "Maksymalnie 4000 znaków." }
        ShowResult (AgentRequest "POST" "/v1/messages" @{sender="user";recipient=$to;message=$message})
        (Get-UIElement "MessageBox").Clear()
    } catch { (Get-UIElement "OutputBox").Text = $_.Exception.Message }
})
$window.Add_KeyDown({
    if ($_.Key -eq [System.Windows.Input.Key]::Escape) { $window.WindowState = "Minimized" }
})
[void]$window.ShowDialog()
