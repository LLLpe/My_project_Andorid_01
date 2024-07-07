using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Unity.VisualScripting;
using System.ComponentModel;

public class CreateWindow : EditorWindow
{
    Rect header;
    Rect content;
    Texture2D headerImage;
    Texture2D contentImage;
    string charName;
    float health;
    float mana;
    GameObject prefab;
    CreatorType type;
    GUISkin guiSkin;

    [MenuItem("PaxtonLiu/OpeneWindows")]
 public static void OpeneWindows() //自定义名称
 {
    CreateWindow window = (CreateWindow)EditorWindow.GetWindow(typeof(CreateWindow));
    
    window.minSize = new Vector2(300,300);
    window.maxSize = new Vector2(600,900);
    window.Show();
 }

private void OnEnable() //类似Start，因为只读取一次
{
    //以下内容之绘制一次
    // headerImage = Resources.Load<Texture2D>("Icons_01");
    // contentImage = Resources.Load<Texture2D>("Icons_02");
    guiSkin = Resources.Load<GUISkin>("CreatorWindowGUISkin");
}
 private void OnGUI()
 {
    header.x = 0;
    header.y = 0;
    header.width = Screen.width ;
    header.height = 30;
    // Debug.Log("屏幕宽度为：" + header.width);
    // header.width = 600;

    content.x = 0;
    content.y = 30;
    content.width = Screen.width;
    content.height = Screen.height - header.height;

    // GUI.DrawTexture(header ,headerImage);
    // GUI.DrawTexture(content ,contentImage);

    GUILayout.BeginArea(header);
    // GUI.skin.label.alignment = TextAnchor.MiddleCenter;
    GUILayout.Label("HEADER",guiSkin.GetStyle("BlackBig"));
    // GUILayout.Label("HEADER");
    GUILayout.EndArea();

    // EditorGUILayout.BeginHorizontal();
    // GUILayout.Label("Name:");
    // charName = EditorGUILayout.TextField(charName);
    // EditorGUILayout.EndHorizontal();

    GUILayout.BeginArea(content);
    // GUI.skin.label.alignment = TextAnchor.UpperLeft;
    // GUILayout.Space(20);
    GUILayout.Label("CONTENT");

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Name:");
        charName = EditorGUILayout.TextField(charName);
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Health:");
        health = EditorGUILayout.FloatField(health);
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Mana:");
        mana = EditorGUILayout.Slider(mana,0,100);
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Prefab:");
        prefab = (GameObject)EditorGUILayout.ObjectField(prefab,typeof(GameObject) ,false);
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Type:");
        type = (CreatorType)EditorGUILayout.EnumPopup(type);
        EditorGUILayout.EndHorizontal();

        if(prefab ==null)
        {
            EditorGUILayout.HelpBox("请添加Prefab文件",MessageType.Warning);
        }
        else if(GUILayout.Button("Creat" ,GUILayout.Height(30)))
        {
            CreateTest();
        }
    GUILayout.EndArea();




 }
public void CreateTest()
    {
        string oldpath;
        string newpath = "Assets/Me/Proj_Code_UnityTool/CreateTest/" + "CT_" + charName + ".prefab";
        oldpath = AssetDatabase.GetAssetPath(prefab);
        AssetDatabase.CopyAsset(oldpath,newpath);
        Debug.Log("执行CreateTest："+ newpath);
        AssetDatabase.Refresh();

        GameObject newPrefab = (GameObject)AssetDatabase.LoadAssetAtPath(newpath,typeof(GameObject)); //获取新生成的Prefab
        if(newPrefab.GetComponent<PrefabInfo>() == null)
        {
            PrefabInfo prefabInfo = newPrefab.AddComponent<PrefabInfo>();
            prefabInfo.charName = charName;
            prefabInfo.health = health;
            prefabInfo.type = type;
            Debug.Log("生效");
        }
        else
        {
            PrefabInfo prefabInfo = newPrefab.GetComponent<PrefabInfo>();
            prefabInfo.charName = charName;
            prefabInfo.health = health;
            prefabInfo.type = type;
            Debug.Log("生效");
        }
    }
}
public enum CreatorType
    {
        T,
        N,
        DPS
    }
