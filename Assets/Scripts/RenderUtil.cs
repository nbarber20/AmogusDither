using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode]
public class RenderUtil : MonoBehaviour
{
    [SerializeField]
    private RawImage output = null;

    private Camera m_camera = null;
    private Vector2Int m_screenSize = Vector2Int.zero;

    private void Awake()
    {
        m_camera = GetComponent<Camera>();
    }

    private void Update()
    {
        if (output == null) return;

        Vector2Int size = new Vector2Int(Screen.width, Screen.height);
        if (m_screenSize != size)
        {
            m_screenSize = size;
            UpdateRenderTex();
        }
    }

    private void UpdateRenderTex()
    {
        if (m_camera.targetTexture != null)
        {
            m_camera.targetTexture.Release();
        }
        RenderTexture renderTex = new RenderTexture(Screen.width, Screen.height, 24);
        m_camera.targetTexture = renderTex;
        output.texture = renderTex;
    }
}
