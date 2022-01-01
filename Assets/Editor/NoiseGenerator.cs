using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;

public class NoiseGenerator : EditorWindow
{
    public enum NoiseType
    {
        Perlin,
        Simplex,
        Worley,
        WorleyVariant1,
        WorleyVariant2,
        Cloud,
    }

    public enum NoiseCreatorImageSize
    {
        SIZE_32 = 32,
        SIZE_64 = 64,
        SIZE_128 = 128,
        SIZE_256 = 256,
        SIZE_512 = 512,
    }

    private NoiseCreatorImageSize m_imageSize;

    static RenderTexture m_renderTexture;
    private Material mat;
    private float m_scale;
    private bool m_tilable;
    private float m_tillingScale;
    private bool m_fbmEnabled;
    private float m_fbmStep;
    private float m_offset;
    private string m_fileName = "noise";
    private bool m_animated;
    private NoiseType m_noiseType;

    [MenuItem("Tools/Noise Generator")]
    static void Init()
    {
        // Get existing open window or if none, make a new one:
        NoiseGenerator window = (NoiseGenerator)EditorWindow.GetWindow(typeof(NoiseGenerator));
        window.Show();
    }

    private void OnEnable()
    {
        m_imageSize = NoiseCreatorImageSize.SIZE_256;
        m_scale = 4;
        m_fbmStep = 4;
        m_tillingScale = 4;
        m_noiseType = NoiseType.Perlin;
        titleContent.text = "Noise Generator";
        position.Set(position.x, position.y, 400, 600);
        minSize = new Vector2(720, 480);
        maxSize = new Vector2(1920, 1080);
        if (m_renderTexture == null)
        {
            m_renderTexture = new RenderTexture(512, 512, 0);
        }
    }
    private void OnDisable()
    {
        m_renderTexture.Release();
    }

    void Update()
    {
        if (m_animated)
        {
            Shader.SetGlobalFloat("_EditorTime", (float)EditorApplication.timeSinceStartup);
        }
        Repaint();
    }

    private void CheckVar()
    {
        if (mat == null || mat.shader.name != "Unlit/" + m_noiseType.ToString() + "Noise")
        {
            mat = new Material(Shader.Find("Unlit/" + m_noiseType.ToString() + "Noise"));
        }

    }

    public void SaveToPNG(RenderTexture rt)
    {
        RenderTexture.active = rt;
        var newRT = RenderTexture.GetTemporary((int)m_imageSize, (int)m_imageSize);
        Graphics.Blit(rt, newRT);
        RenderTexture.active = newRT;
        Texture2D tex = new Texture2D((int)m_imageSize, (int)m_imageSize, TextureFormat.ARGB32, 0, true);
        tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
        RenderTexture.active = null;
        byte[] bytes;
        bytes = tex.EncodeToPNG();

        string path = "Assets/" + m_fileName + ".png";
        System.IO.File.WriteAllBytes(path, bytes);
        AssetDatabase.ImportAsset(path);
        Debug.LogWarning("noise texture save to " + path);
        DestroyImmediate(tex);
    }

    private void OnGUI()
    {
        CheckVar();
        EditorGUILayout.BeginHorizontal();
        EditorGUI.DrawPreviewTexture(new Rect(0, 0, 256, 256), m_renderTexture, mat);
        EditorGUILayout.Space(256);
        EditorGUILayout.BeginVertical();
        m_noiseType = (NoiseType)EditorGUILayout.EnumPopup("Noise Type", m_noiseType);
        m_animated = EditorGUILayout.Toggle("Animated", m_animated);
        m_scale = EditorGUILayout.IntSlider("Scale", (int)m_scale, 2, 12);
        mat.SetFloat("_Scale", m_scale);
        m_offset = EditorGUILayout.Slider("Offset", m_offset, 0, 1024f);
        mat.SetFloat("_Offset", m_offset);

        EditorGUILayout.Space(10);
        m_tilable = EditorGUILayout.BeginToggleGroup("Is Tilable/Seamless", m_tilable);
        EditorGUI.indentLevel++;
        m_tillingScale = EditorGUILayout.IntSlider("Tiling Scale", (int)m_tillingScale, 2, 4);
        mat.SetFloat("_Periodic", m_tillingScale);
        mat.SetFloat("_Tilable", m_tilable ? 1.0f : 0f);
        EditorGUI.indentLevel--;
        EditorGUILayout.EndToggleGroup();

        EditorGUILayout.Space(10);
        m_fbmEnabled = EditorGUILayout.BeginToggleGroup("Enable FBM", m_fbmEnabled);
        EditorGUI.indentLevel++;
        m_fbmStep = EditorGUILayout.IntSlider("FBM Step", (int)m_fbmStep, 1, 10);
        mat.SetFloat("_FbmStep", m_fbmStep);
        mat.SetFloat("_FbmEnabled", m_fbmEnabled ? 1.0f : 0f);
        EditorGUI.indentLevel--;
        EditorGUILayout.EndToggleGroup();

        EditorGUILayout.EndVertical();
        EditorGUILayout.EndHorizontal();
        m_imageSize = (NoiseCreatorImageSize)EditorGUILayout.EnumPopup("Image Size", m_imageSize);
        GUILayout.Label("Save Image Settings", EditorStyles.boldLabel);
        if (GUILayout.Button("Save To PNG"))
        {
            var temp = RenderTexture.GetTemporary(m_renderTexture.width, m_renderTexture.height);
            RenderTexture.active = temp;
            Graphics.Blit(temp, m_renderTexture, mat);
            RenderTexture.active = null;
            temp.Release();
            SaveToPNG(m_renderTexture);
        }
        m_fileName = EditorGUILayout.TextField("File Name", m_fileName);
    }
}
