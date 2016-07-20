using UnityEngine;
using System.Collections;
using UnityStandardAssets.ImageEffects;

public enum DebugFrame
{
    Src,
    Dst,
    Compose,
    //Depth,
    //SrcCutout,
    //DstCutout,
    WorldPos,
    //Effect,
    //Cutout,
    //EdgeCutout,
    //EdgeCutoutBloom,
    //FinalCompose
};

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class DepthEffect : MonoBehaviour
{
    public int _NumFrequencies;

    public float _EdgeWidth;
    public float _FringeSize;
    public float _NoiseScale;
    public float DistanceThreshold;
    public Vector3 StartEffectPos;
    public Color EdgeColor;

    public Texture2D RandomTexture;

    public LayerMask SourceLayerMask;
    public LayerMask DestinationLayerMask;

    public Shader CutoutShader;
    public Shader CutoutEdgeShader;
    public Shader WorldPosShader;
    public Material EffectMaterial;
    public DebugFrame DebugTexture;

    private bool _fetchPos;
    private Vector2 _mousePos;
    private GameObject _ppCameraGO = null;

    // Use this for initialization
    void Start ()
    {
	
	}

    private Camera GetPPCamera()
    {
        if (_ppCameraGO == null)
        {
            _ppCameraGO = GameObject.Find("Post Processing Camera");

            if (_ppCameraGO == null)
            {
                _ppCameraGO = new GameObject("Post Processing Camera", typeof(Camera));
                _ppCameraGO.AddComponent<UltimateBloom>();
                _ppCameraGO.GetComponent<UltimateBloom>().enabled = false;
                _ppCameraGO.transform.parent = transform;
            }

            if (_ppCameraGO.GetComponent<Camera>() == null)
            {
                _ppCameraGO.AddComponent<Camera>();
                _ppCameraGO.AddComponent<UltimateBloom>();
                _ppCameraGO.GetComponent<UltimateBloom>().enabled = false;
            }

            _ppCameraGO.GetComponent<Camera>().CopyFrom(GetComponent<Camera>());
            _ppCameraGO.GetComponent<Camera>().clearFlags = CameraClearFlags.Nothing;
            _ppCameraGO.GetComponent<Camera>().enabled = false;

        }
        return _ppCameraGO.GetComponent<Camera>();
    }

    private void OnGUI()
    {
        if (Event.current.control && Event.current.type == EventType.MouseDown && Event.current.button == 2)
        {
            //DebugTexture.Log("Mouse click: " + Event.current.mousePosition);

            _fetchPos = true;
            _mousePos = Event.current.mousePosition;
        }
    }

    public int MSAA = 0;

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        var ppCamera = GetPPCamera();

        var composeTexture = RenderTexture.GetTemporary(src.width, src.height, 24, RenderTextureFormat.ARGB32);

        var srcColorTexture = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Default);
        var srcDepthTexture = RenderTexture.GetTemporary(src.width, src.height, 24, RenderTextureFormat.Depth, RenderTextureReadWrite.Default);

        var dstColorTexture = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Default);
        var dstDepthTexture = RenderTexture.GetTemporary(src.width, src.height, 24, RenderTextureFormat.Depth, RenderTextureReadWrite.Default);

        Graphics.SetRenderTarget(srcColorTexture.colorBuffer, srcDepthTexture.depthBuffer);
        GL.Clear(true, true, Color.white);

        Graphics.SetRenderTarget(dstColorTexture.colorBuffer, dstDepthTexture.depthBuffer);
        GL.Clear(true, true, Color.white);

        Graphics.SetRenderTarget(composeTexture);
        GL.Clear(true, true, Color.white);

        //var cutoutTexture = RenderTexture.GetTemporary(src.width, src.height, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Default, MSAA);
        //var cutoutEdgeTexture = RenderTexture.GetTemporary(src.width, src.height, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Default, MSAA);
        //var cutoutComposeTexture = RenderTexture.GetTemporary(src.width, src.height, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Default, MSAA);

        //Graphics.SetRenderTarget(cutoutTexture);
        //GL.Clear(true, true, Color.white);

        //Graphics.SetRenderTarget(cutoutEdgeTexture);
        //GL.Clear(true, true, Color.black);


        //**************** Cutout *********************//

        // Set cutout shader properties

        //Shader.SetGlobalInt("_NumFrequencies", _NumFrequencies);
        //Shader.SetGlobalFloat("_EdgeWidth", _EdgeWidth);
        //Shader.SetGlobalFloat("_FringeSize", _FringeSize);
        //Shader.SetGlobalFloat("_NoiseScale", _NoiseScale);
        //Shader.SetGlobalFloat("_DistanceThreshold", DistanceThreshold);
        //Shader.SetGlobalVector("_EdgeColor", EdgeColor);
        //Shader.SetGlobalVector("_StartEffectPos", StartEffectPos);

        //**************** Source *********************//
        
        // Set src layer mask
        ppCamera.cullingMask = SourceLayerMask.value;

        // Render src model
        ppCamera.SetTargetBuffers(srcColorTexture.colorBuffer, srcDepthTexture.depthBuffer);
        ppCamera.Render();
        
        //// Render src cutout
        //ppCamera.targetTexture = cutoutTexture;
        
        //Shader.EnableKeyword("SRC");
        //ppCamera.RenderWithShader(CutoutShader, "RenderType");
        //Shader.DisableKeyword("SRC");


        //// Render src edge cutout
        //ppCamera.targetTexture = cutoutEdgeTexture;
        
        //Shader.EnableKeyword("SRC");
        //ppCamera.RenderWithShader(CutoutEdgeShader, "RenderType");
        //Shader.DisableKeyword("SRC");

        //**************** Destination *********************//

        // Set dst layer mask
        ppCamera.cullingMask = DestinationLayerMask.value;

        // Render dst model
        ppCamera.SetTargetBuffers(dstColorTexture.colorBuffer, dstDepthTexture.depthBuffer);
        ppCamera.Render();
        
        //// Render dst cutout
        //ppCamera.targetTexture = cutoutTexture;

        //Shader.EnableKeyword("DST");
        //ppCamera.RenderWithShader(CutoutShader, "RenderType");
        //Shader.DisableKeyword("DST");


        //// Render dst edge cutout
        //ppCamera.targetTexture = cutoutEdgeTexture;

        //Shader.EnableKeyword("DST");
        //ppCamera.RenderWithShader(CutoutEdgeShader, "RenderType");
        //Shader.DisableKeyword("DST");

        //**************** Fetch World Mouse Pos ***********//

        if (_fetchPos || DebugTexture == DebugFrame.WorldPos)
        { 
            var worldPosTexture = RenderTexture.GetTemporary(src.width, src.height, 24, RenderTextureFormat.ARGBFloat);

            Graphics.SetRenderTarget(worldPosTexture);
            GL.Clear(true, true, Color.white);

            // Render world pos texture

            Shader.SetGlobalMatrix("_InverseView", ppCamera.cameraToWorldMatrix);

            ppCamera.cullingMask = (1 << (int)Mathf.Log(SourceLayerMask.value, 2));
            ppCamera.SetTargetBuffers(worldPosTexture.colorBuffer, worldPosTexture.depthBuffer);
            ppCamera.RenderWithShader(WorldPosShader, "");

            if(DebugTexture == DebugFrame.WorldPos)
                Graphics.Blit(worldPosTexture, dst);

            if(_fetchPos)
            {
                var worldPosTex = new Texture2D(src.width, src.height, TextureFormat.RGBAFloat, false);

                RenderTexture.active = worldPosTexture;
                worldPosTex.ReadPixels(new Rect(0, 0, src.width, src.height), 0, 0);
                worldPosTex.Apply();

                var pixel = worldPosTex.GetPixel((int)_mousePos.x, src.height - (int)_mousePos.y);
                StartEffectPos = new Vector3(pixel.r, pixel.g, pixel.b);

                Debug.Log(_mousePos);
                Debug.Log(pixel);

                _fetchPos = false;
                RenderTexture.active = null; // added to avoid errors 

                DestroyImmediate(worldPosTex);
            }
            
            RenderTexture.ReleaseTemporary(worldPosTexture);
        }


        //**************** Compose Effect *********************//

        Matrix4x4 mat = (GetComponent<Camera>().projectionMatrix * GetComponent<Camera>().worldToCameraMatrix).inverse;

        EffectMaterial.SetInt("_NumFrequencies", _NumFrequencies);
        EffectMaterial.SetFloat("_EdgeWidth", _EdgeWidth);
        EffectMaterial.SetFloat("_FringeSize", _FringeSize);
        EffectMaterial.SetFloat("_NoiseScale", _NoiseScale);

        EffectMaterial.SetFloat("_DistanceThreshold", DistanceThreshold);
        EffectMaterial.SetVector("_StartEffectPos", StartEffectPos);
        EffectMaterial.SetMatrix("_InverseView", GetComponent<Camera>().cameraToWorldMatrix);
        
        EffectMaterial.SetTexture("_RandomTexture", RandomTexture);
        EffectMaterial.SetTexture("_SrcColorTexture", srcColorTexture);
        EffectMaterial.SetTexture("_SrcDepthTexture", srcDepthTexture);
        EffectMaterial.SetTexture("_DstColorTexture", dstColorTexture);
        EffectMaterial.SetTexture("_DstDepthTexture", dstDepthTexture);

        Graphics.Blit(dstColorTexture, composeTexture);
        Graphics.Blit(null, composeTexture, EffectMaterial, 0);

        //**************** Bloom effect *********************//

        //var bloom = ppCamera.GetComponent<UltimateBloom>();
        //bloom.OnRenderImage(cutoutEdgeTexture, cutoutComposeTexture);

        //**************** Final *********************//
        
        switch (DebugTexture)
        {
            case DebugFrame.Src:
                Graphics.Blit(srcColorTexture, dst);
               break;

            case DebugFrame.Dst:
                Graphics.Blit(dstColorTexture, dst);
                break;

            //case DebugFrame.Depth:
            //    Graphics.Blit(srcDepthTexture, dst);
            //    break;

            case DebugFrame.Compose:
                Graphics.Blit(composeTexture, dst);
                break;

            //case DebugFrame.Cutout:
            //    Graphics.Blit(cutoutTexture, dst);
            //    break;

            //case DebugFrame.EdgeCutout:
            //    Graphics.Blit(cutoutEdgeTexture, dst);
            //    //Graphics.Blit(cutoutComposeTexture, dst);
            //    break;

            //case DebugFrame.EdgeCutoutBloom:
            //    Graphics.Blit(cutoutComposeTexture, dst);
            //    break;

            //case DebugFrame.FinalCompose:

            //    Graphics.Blit(cutoutComposeTexture, cutoutTexture, EffectMaterial, 1);
            //    Graphics.Blit(cutoutTexture, dst);
            //    break;

            default:
                break;
        }
        
        RenderTexture.ReleaseTemporary(composeTexture);

        RenderTexture.ReleaseTemporary(srcColorTexture);
        RenderTexture.ReleaseTemporary(srcDepthTexture);

        RenderTexture.ReleaseTemporary(dstColorTexture);
        RenderTexture.ReleaseTemporary(dstDepthTexture);
        
        //RenderTexture.ReleaseTemporary(cutoutTexture);
        //RenderTexture.ReleaseTemporary(cutoutEdgeTexture);
        //RenderTexture.ReleaseTemporary(cutoutComposeTexture);
    }
}
