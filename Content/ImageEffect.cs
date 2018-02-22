using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ImageEffect : MonoBehaviour 
{

	public Material mat;

	void OnRenderImage (RenderTexture src, RenderTexture dst)
	{		
		Graphics.Blit (src, dst, mat);
	}
}