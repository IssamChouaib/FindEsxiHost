Add-Type -AssemblyName System.Windows.Forms, System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Programa metadata
$progName = 'FindEsxiHost.exe'
$version = '1.0'
$author = 'Issam Chouaib'
$copyright = 'Licensed for free distribution'

# Form principal
$form = New-Object System.Windows.Forms.Form
$form.Text = "ESXi Scanner"
$form.Size = New-Object System.Drawing.Size(600,600)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

# MenuStrip y menú About
$menu = New-Object System.Windows.Forms.MenuStrip
$menuAbout = New-Object System.Windows.Forms.ToolStripMenuItem("About")
$menu.Items.Add($menuAbout) | Out-Null
$form.MainMenuStrip = $menu
$form.Controls.Add($menu)

# Handler para About
$menuAbout.Add_Click({
    $msg = "$progName`r`nVersion: $version`r`nAuthor: $author`r`n© $copyright"
    [System.Windows.Forms.MessageBox]::Show($msg, 'About', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})

# Controles de entrada
$lblStart = New-Object System.Windows.Forms.Label
$lblStart.Text = "Start IP:"; $lblStart.Location = New-Object Drawing.Point(10,40); $lblStart.AutoSize = $true
$txtStart = New-Object System.Windows.Forms.TextBox; $txtStart.Location = New-Object Drawing.Point(100,38); $txtStart.Width = 200

$lblEnd = New-Object System.Windows.Forms.Label
$lblEnd.Text = "End IP:"; $lblEnd.Location = New-Object Drawing.Point(10,80); $lblEnd.AutoSize = $true
$txtEnd = New-Object System.Windows.Forms.TextBox; $txtEnd.Location = New-Object Drawing.Point(100,78); $txtEnd.Width = 200

$lblTimeout = New-Object System.Windows.Forms.Label
$lblTimeout.Text = "Timeout (ms):"; $lblTimeout.Location = New-Object Drawing.Point(10,120); $lblTimeout.AutoSize = $true
$txtTimeout = New-Object System.Windows.Forms.TextBox; $txtTimeout.Location = New-Object Drawing.Point(100,118); $txtTimeout.Width = 80; $txtTimeout.Text = '50'

# Botón de escaneo destacado
$btnScan = New-Object System.Windows.Forms.Button
$btnScan.Text = 'Start Scan'; $btnScan.Location = New-Object Drawing.Point(320,38); $btnScan.Size = New-Object Drawing.Size(120,40)
$btnScan.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnScan.BackColor = [System.Drawing.Color]::SteelBlue; $btnScan.ForeColor = [System.Drawing.Color]::White
$btnScan.FlatAppearance.BorderSize = 0
$btnScan.Add_MouseEnter({ $btnScan.BackColor = [System.Drawing.Color]::DarkBlue })
$btnScan.Add_MouseLeave({ $btnScan.BackColor = [System.Drawing.Color]::SteelBlue })

# Botón de exportación unificado
$btnExport = New-Object System.Windows.Forms.Button
$btnExport.Text = 'Export Results'; $btnExport.Location = New-Object Drawing.Point(320,88); $btnExport.Size = New-Object Drawing.Size(120,23)

# Barra de progreso y etiqueta de estado
$pb = New-Object System.Windows.Forms.ProgressBar
$pb.Location = New-Object Drawing.Point(10,160); $pb.Size = New-Object Drawing.Size(560,20); $pb.Minimum = 0; $pb.Value = 0
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = 'Idle...'; $lblStatus.Location = New-Object Drawing.Point(10,185); $lblStatus.Size = New-Object Drawing.Size(560,20)

# ListView de resultados
$lv = New-Object System.Windows.Forms.ListView
$lv.Location = New-Object Drawing.Point(10,210); $lv.Size = New-Object Drawing.Size(560,350)
$lv.View = 'Details'; $lv.FullRowSelect = $true
$lv.Columns.Add('IP',150) | Out-Null
$lv.Columns.Add('Is ESXi?',80) | Out-Null
$lv.Columns.Add('Banner',320) | Out-Null

$form.Controls.AddRange(@($lblStart,$txtStart,$lblEnd,$txtEnd,$lblTimeout,$txtTimeout,$btnScan,$btnExport,$pb,$lblStatus,$lv))

# Funciones utilitarias
function Next-IP([byte[]]$b){ for($i=$b.Length-1;$i -ge 0;$i--){ if($b[$i] -lt 255){$b[$i]++; break}; $b[$i]=0 }; return $b }
function Test-PortFast { param($ip,$port=902,$timeout)
  try {
    $tcp = New-Object Net.Sockets.TcpClient
    $task = $tcp.ConnectAsync($ip,$port)
    if(-not $task.Wait($timeout)){ $tcp.Close(); return $null }
    if(-not $tcp.Connected){ $tcp.Close(); return $null }
    $stream = $tcp.GetStream(); $stream.ReadTimeout = $timeout
    $buf = New-Object byte[] 128; $len = $stream.Read($buf,0,$buf.Length); $tcp.Close()
    if($len -gt 0){ return [Text.Encoding]::ASCII.GetString($buf,0,$len) } else { return "" }
  } catch { return $null }
}

# Evento Start Scan
$btnScan.Add_Click({
  $lv.Items.Clear(); $lblStatus.Text = 'Validating input...'; [System.Windows.Forms.Application]::DoEvents()
  try {
    $start = [Net.IPAddress]::Parse($txtStart.Text).GetAddressBytes()
    $end = [Net.IPAddress]::Parse($txtEnd.Text).GetAddressBytes()
    $timeout = [int]$txtTimeout.Text
  } catch {
    [System.Windows.Forms.MessageBox]::Show('Invalid input.','Error',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
    return
  }
  $list = @(); $cur = $start.Clone()
  do { $list += [string]::Join('.', $cur); $cur = Next-IP($cur) } while((Compare-Object $cur $end).Count -ne 0)
  $list += [string]::Join('.', $end); $total = $list.Count; $pb.Maximum = $total; $pb.Value = 0; $lblStatus.Text = "Scanning 0 of $total..."
  for($i=0;$i -lt $total;$i++){
    $ip = $list[$i]; $banner = Test-PortFast -ip $ip -timeout $timeout; $pb.Value = $i+1
    $lblStatus.Text = ("Scanning {0} of {1}: {2}" -f ($i+1), $total, $ip)
    if($banner -ne $null){
      $is = ($banner -match 'VMware' -or $banner -match 'esx')
      $li = New-Object System.Windows.Forms.ListViewItem($ip)
      $li.SubItems.Add($is.ToString()) | Out-Null
      $li.SubItems.Add(($banner -replace "[\r\n]+"," ")) | Out-Null
      $lv.Items.Add($li) | Out-Null
    }
    [System.Windows.Forms.Application]::DoEvents()
  }
  $lblStatus.Text = "Scan complete ($total IPs processed)"
})

# Evento Export
$btnExport.Add_Click({
  if($lv.Items.Count -eq 0){
    [System.Windows.Forms.MessageBox]::Show('No results to export.','Info',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
    return
  }
  $dlg = New-Object System.Windows.Forms.SaveFileDialog
  $dlg.Title = 'Export results as...'
  $dlg.Filter = 'Text (*.txt)|*.txt|CSV (*.csv)|*.csv|HTML (*.html;*.htm)|*.html;*.htm'
  if($dlg.ShowDialog() -eq 'OK'){
    $ext = [System.IO.Path]::GetExtension($dlg.FileName).ToLower()
    $objs = $lv.Items | ForEach-Object { [PSCustomObject]@{ IP=$_.Text; IsESXi=$_.SubItems[1].Text; Banner=$_.SubItems[2].Text } }
    switch($ext){
      '.txt' { $objs | ForEach-Object { "{0}`t{1}`t{2}" -f $_.IP,$_.IsESXi,$_.Banner } | Out-File -FilePath $dlg.FileName -Encoding UTF8 }
      '.csv' { $objs | Export-Csv -Path $dlg.FileName -NoTypeInformation -Encoding UTF8 }
      '.htm' { $objs | ConvertTo-Html -Property IP,IsESXi,Banner -Title 'ESXi Scan Results' | Out-File $dlg.FileName -Encoding UTF8 }
      '.html' { $objs | ConvertTo-Html -Property IP,IsESXi,Banner -Title 'Esxi Scan Results' | Out-File $dlg.FileName -Encoding UTF8 }
    }
    [System.Windows.Forms.MessageBox]::Show('Export successful','Info',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
  }
})

[void]$form.ShowDialog()
