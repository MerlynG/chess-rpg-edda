using Godot;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Runtime.InteropServices;

public partial class stockfish_connector : Node
{
	Process process;
	StreamWriter inputWriter;
	StreamReader outputReader;

	public void Init()
	{
		string path = "";
		if(RuntimeInformation.IsOSPlatform(OSPlatform.Windows)) {
			path = "stock-fish/stockfish_win/stockfish-windows-x86-64-avx2.exe";
		} else {
			path = "stock-fish/stockfish_lin/stockfish-ubuntu-x86-64-avx2";
		}

		process = new Process();
		process.StartInfo.FileName = path;
		process.StartInfo.Arguments = "";
		process.StartInfo.UseShellExecute = false;
		process.StartInfo.RedirectStandardInput = true;
		process.StartInfo.RedirectStandardOutput = true;
		process.StartInfo.RedirectStandardError = true;
		process.StartInfo.CreateNoWindow = true;

		bool success = process.Start();

		if (!success)
		{
			var errorMsg = process.StandardError.ReadToEnd();
			GD.PrintErr("Erreur Stockfish :", errorMsg);
			return;
		}

		inputWriter = process.StandardInput;
		outputReader = process.StandardOutput;
	}

	public void SendInput(string input)
	{
		inputWriter.WriteLine(input);
		inputWriter.Flush();
	}

	public string ReadOutput()
	{
		return outputReader.ReadLine();
	}
	
	public string ReadAllAvailableOutput(string stopWord)
	{
		if (outputReader == null)
		{
			GD.PrintErr("outputReader NULL");
			return "";
		}

		if (outputReader.EndOfStream)
		{
			GD.Print("Flux terminé (EndOfStream)");
			return "";
		}
		
		var output = new StringBuilder();
		var line = "";
		while (!line.Contains(stopWord))
		{
			line = outputReader.ReadLine();
			if (line != null)
				if(RuntimeInformation.IsOSPlatform(OSPlatform.Windows)) {
					//GD.Print(line);
					output.Append(line + "\n");
				} else {
					output.AppendLine(line);
				}
		}

		return output.ToString();
	}
}
