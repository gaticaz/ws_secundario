<?php
/**
 * Esta clase fue y será generada automáticamente. NO EDITAR A MANO.
 * @ignore
 */
class ws_secundario_autoload 
{
	static function existe_clase($nombre)
	{
		return isset(self::$clases[$nombre]);
	}

	static function cargar($nombre)
	{
		if (self::existe_clase($nombre)) { 
			 require_once(dirname(__FILE__) .'/'. self::$clases[$nombre]); 
		}
	}

	static protected $clases = array(
		'ws_secundario_ci' => 'extension_toba/componentes/ws_secundario_ci.php',
		'ws_secundario_cn' => 'extension_toba/componentes/ws_secundario_cn.php',
		'ws_secundario_datos_relacion' => 'extension_toba/componentes/ws_secundario_datos_relacion.php',
		'ws_secundario_datos_tabla' => 'extension_toba/componentes/ws_secundario_datos_tabla.php',
		'ws_secundario_ei_arbol' => 'extension_toba/componentes/ws_secundario_ei_arbol.php',
		'ws_secundario_ei_archivos' => 'extension_toba/componentes/ws_secundario_ei_archivos.php',
		'ws_secundario_ei_calendario' => 'extension_toba/componentes/ws_secundario_ei_calendario.php',
		'ws_secundario_ei_codigo' => 'extension_toba/componentes/ws_secundario_ei_codigo.php',
		'ws_secundario_ei_cuadro' => 'extension_toba/componentes/ws_secundario_ei_cuadro.php',
		'ws_secundario_ei_esquema' => 'extension_toba/componentes/ws_secundario_ei_esquema.php',
		'ws_secundario_ei_filtro' => 'extension_toba/componentes/ws_secundario_ei_filtro.php',
		'ws_secundario_ei_firma' => 'extension_toba/componentes/ws_secundario_ei_firma.php',
		'ws_secundario_ei_formulario' => 'extension_toba/componentes/ws_secundario_ei_formulario.php',
		'ws_secundario_ei_formulario_ml' => 'extension_toba/componentes/ws_secundario_ei_formulario_ml.php',
		'ws_secundario_ei_grafico' => 'extension_toba/componentes/ws_secundario_ei_grafico.php',
		'ws_secundario_ei_mapa' => 'extension_toba/componentes/ws_secundario_ei_mapa.php',
		'ws_secundario_servicio_web' => 'extension_toba/componentes/ws_secundario_servicio_web.php',
		'ws_secundario_comando' => 'extension_toba/ws_secundario_comando.php',
		'ws_secundario_modelo' => 'extension_toba/ws_secundario_modelo.php',
	);
}
?>