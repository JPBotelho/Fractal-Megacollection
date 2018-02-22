using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class FractalEditor : ShaderGUI 
{
	int x = 1920;
	int y = 1080;

	public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
		base.OnGUI(materialEditor, properties);

		EditorGUILayout.Space();
		EditorGUILayout.Space();

		GUILayoutOption height = GUILayout.Height(50);

		EditorGUILayout.BeginVertical(EditorStyles.helpBox);

		x = EditorGUILayout.IntField("X resolution ", x);
		y = EditorGUILayout.IntField("Y resolution ", y);

		EditorGUILayout.Space();

		if (GUILayout.Button("Export", height))
		{
			ExportImage(x, y, (Material)materialEditor.target);
		}

		EditorGUILayout.EndVertical();
	}

	public static string GetImagePath ()
	{
		string path = EditorUtility.SaveFilePanel ("Save Image", Application.dataPath, "Fractal", "png");

		return path;
	}

	public static Texture2D GetRender (int x, int y, Material mat)
	{
		Texture2D source = new Texture2D(x, y);
		RenderTexture renderTarget = new RenderTexture(x, y, 0);

		Graphics.Blit(source, renderTarget, mat);

		Texture2D texture = FromRenderTexture(x, y, renderTarget);

		return texture;
	}
	public static void ExportImage (int x, int y, Material mat)
	{
		string path = GetImagePath();

		if (!string.IsNullOrEmpty(path))
		{
			Texture2D renderOutput = GetRender(x, y, mat);
			byte[] bytes = renderOutput.EncodeToPNG();

			System.IO.File.WriteAllBytes(path, bytes);
			AssetDatabase.Refresh();
		}
	}

	public static Texture2D FromRenderTexture (int x, int y, RenderTexture rt)
	{
		Texture2D texture = new Texture2D (x, y, TextureFormat.RGB24, false);

		RenderTexture.active = rt;

		texture.ReadPixels(new Rect(0, 0, x, y), 0, 0);
 		texture.Apply();

		RenderTexture.active = null;
		rt.Release();

		return texture;
	}
}
