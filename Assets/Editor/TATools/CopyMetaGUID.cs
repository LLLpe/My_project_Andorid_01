using UnityEditor;
using UnityEngine;
using System.IO;

public class CopyMetaGUID 
{
    [MenuItem("Assets/TATools/Copy Meta GUID", false, 1)]
    private static void CopyMetaGUIDToClipboard()
    {
        // 获取选中的资产路径
        string assetPath = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (string.IsNullOrEmpty(assetPath))
        {
            Debug.LogError("请选择一个资产文件。");
            return;
        }

        // 获取.meta文件路径
        string metaFilePath = assetPath + ".meta";

        if (!File.Exists(metaFilePath))
        {
            Debug.LogError("未找到.meta文件。");
            return;
        }

        // 读取.meta文件内容
        string[] metaFileLines = File.ReadAllLines(metaFilePath);

        // 找到并复制GUID
        foreach (string line in metaFileLines)
        {
            if (line.StartsWith("guid: "))
            {
                string guid = line.Substring("guid: ".Length);
                GUIUtility.systemCopyBuffer = guid;
                Debug.Log($"GUID: {guid} 已复制到剪贴板。");
                return;
            }
        }

        Debug.LogError("未找到GUID。");
    }

    [MenuItem("Assets/TATools/Copy Meta GUID", true)]
    private static bool ValidateCopyMetaGUIDToClipboard()
    {
        // 仅在选中资产时启用菜单项
        return Selection.activeObject != null;
    }
}
