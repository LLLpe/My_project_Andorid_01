using UnityEditor;
using UnityEngine;
using System.Diagnostics;

public class GitContextMenu : MonoBehaviour
{
    [MenuItem("Assets/Git/Commit", false, 1)]
    private static void Commit()
    {
        ExecuteGitCommand("commit -m \"Your commit message\"");
    }

    [MenuItem("Assets/Git/Push", false, 2)]
    private static void Push()
    {
        ExecuteGitCommand("push");
    }

    [MenuItem("Assets/Git/Pull", false, 3)]
    private static void Pull()
    {
        ExecuteGitCommand("pull");
    }

    private static void ExecuteGitCommand(string command)
    {
        ProcessStartInfo processInfo = new ProcessStartInfo("git", command);
        processInfo.CreateNoWindow = true;
        processInfo.UseShellExecute = false;
        processInfo.RedirectStandardOutput = true;
        processInfo.RedirectStandardError = true;
        Process process = Process.Start(processInfo);

        string output = process.StandardOutput.ReadToEnd();
        string error = process.StandardError.ReadToEnd();

        process.WaitForExit();

        UnityEngine.Debug.Log("Output: " + output);
        UnityEngine.Debug.LogError("Error: " + error);
    }
}
