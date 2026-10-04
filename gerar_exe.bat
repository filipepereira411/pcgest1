@echo off
title Compilador do Gestor de Funcoes
color 0b
echo ====================================================
echo   Compilando Gestor de Funcoes para Executavel
echo ====================================================
echo.

:: Procurar pelo compilador C# nativo do Windows (.NET Framework)
set "csc_path="
for /d %%D in (%SystemRoot%\Microsoft.NET\Framework\v4.0.*) do (
    if exist "%%D\csc.exe" set "csc_path=%%D\csc.exe"
)

if not defined csc_path (
    color 0c
    echo [ERRO] Nao foi possivel encontrar o compilador csc.exe do .NET Framework 4.0+.
    echo Certifique-se de que o .NET Framework esta instalado.
    pause
    exit /b
)

:: Criar o ficheiro de código C# temporário que serve de "casca" para abrir o HTML
echo [1/3] Criando estrutura da aplicacao de janelas...
(
echo using System;
echo using System.Windows.Forms;
echo using System.IO;
echo namespace GestorApp {
echo     static class Program {
echo         [STAThread]
echo         static void Main^(^) {
echo             Application.EnableVisualStyles^(^);
echo             Application.SetCompatibleTextRenderingDefault^(false^);
echo             Form form = new Form^(^);
echo             form.Title = "Gestor de Funcoes do Sistema";
echo             form.Width = 1240;
echo             form.Height = 850;
echo             form.StartPosition = FormStartPosition.CenterScreen;
echo             WebBrowser wb = new WebBrowser^(^);
echo             wb.Dock = DockStyle.Fill;
echo             wb.ScriptErrorsSuppressed = true;
echo             string htmlPath = Path.Combine^(AppDomain.CurrentDomain.BaseDirectory, "gestor.html"^);
echo             if ^(File.Exists^(htmlPath^)^) {
echo                 wb.Navigate^(htmlPath^);
echo             } else {
echo                 MessageBox.Show^("Erro: O ficheiro 'gestor.html' nao foi encontrado na mesma pasta do executavel.", "Erro de Inicializacao", MessageBoxButtons.OK, MessageBoxIcon.Error^);
echo                 return;
echo             }
echo             form.Controls.Add^(wb^);
echo             Application.Run^(form^);
echo         }
echo     }
echo }
) > temp_app.cs

echo [2/3] Compilando codigo em executavel nativo (GestorFuncoes.exe)...
:: Compila o código C# ocultando a janela da consola (/target:winexe)
"%csc_path%" /target:winexe /out:GestorFuncoes.exe temp_app.cs > nul

:: Verificar se a compilação teve sucesso
if exist GestorFuncoes.exe (
    echo [3/3] Limpando ficheiros temporarios...
    del temp_app.cs
    color 0a
    echo.
    echo ====================================================
    echo   SUCESSO! O ficheiro 'GestorFuncoes.exe' foi criado.
    echo   Garanta que o 'gestor.html' continua nesta pasta.
    echo ====================================================
) else (
    color 0c
    echo [ERRO] Falha na compilacao. Verifique se tem permissoes de escrita na pasta.
    if exist temp_app.cs del temp_app.cs
)

echo.
pause
