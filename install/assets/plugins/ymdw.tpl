//<?php
/**
 * Yandex Metrika Dashboard Widget
 *
 * show Visitors, Visits and Pagevisits
 *
 * @category    plugin
 * @version     0.1
 * @license     http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @package     modx
 * @author      Dmi3yy (dmi3yy@gmail.com), Pathologic (maxx@np.by)
 * @internal    @events OnManagerWelcomePrerender
 * @internal    @modx_category Manager and Admin
 * @internal    @properties &app_id = Id приложения;text; &app_pass = Пароль приложения;text; &ym_login = Логин Яндекс;text; &ym_pass = Пароль Яндекс;text; &counter_id = Номер счетчика;text; &counter_range = Количество дней;text;10 &widget_height = Высота виджета;text;350
 * @internal    @installset base
 * @internal    @disabled 1
 */
 
$e = &$modx->Event;
if($e->name == 'OnManagerWelcomePrerender'){	
	if(!file_exists(MODX_BASE_PATH . 'assets/cache/ymdw.widgetCache-'.date('z').'.php')){
		require (MODX_BASE_PATH.'assets/plugins/ymdw/yandexapi.class.php');
		$ym = new YandexAPI($app_id, $app_pass);
		$ym->LogIn($ym_login, $ym_pass);
		if ($ym->success) {
			$counter_range = empty($counter_range) ? 7 : $counter_range;
			$date2 = time();
			$date1 = $date2 - $counter_range*24*60*60;
			$date2 = date('Ymd',$date2);
			$date1 = date('Ymd',$date1);
			$ym->MakeQuery('/stat/traffic/summary', array('id'=>$counter_id,'date1'=>$date1,'date2'=>$date2));
			if ($ym->success) {
				$results = $ym->result;
				$visitors = $visits = $views = $dates = array();
				$results = array_reverse($results['data']);
				foreach ($results as $result) {
					$dates[] = '['.$i.',"'.substr($result['date'],6,2).'.'.substr($result['date'],4,2).'.'.substr($result['date'],0,4).'"]';
					$visitors[] = '['.$i.','.$result['new_visitors'].']';
					$visits[] = '['.$i.','.$result['visits'].']';
					$views[] = '['.$i.','.$result['page_views'].']';
					$i++;											 
				}
				$flot_ticks = '['.implode(',',$dates).']';
				$flot_data_visitors = '['.implode(',',$visitors).']';
				$flot_data_visits = '['.implode(',',$visits).']';
				$flot_data_views = '['.implode(',',$views).']';
				$output = ' <div class="sectionHeader">Яндекс.Метрика</div>
					<div class="sectionBody" id="ymdw" style="height:'.$widget_height.'px"></div>
					<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
					<script language="javascript" type="text/javascript" src="../assets/plugins/ymdw/jquery.flot.min-time.js"></script>
					<style>
					.flot-x-axis .flot-tick-label {
  					-o-transform:rotate(-90deg);
  					-moz-transform: rotate(-90deg);
  					-webkit-transform:rotate(-90deg);
					filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);
					padding:25px;
					}
					</style>
					<script type="text/javascript">
						$(document).ready(function() {
							var visitors = '.$flot_data_visitors.';
							var visits = '.$flot_data_visits.';
							var views = '.$flot_data_views.';
							var ticks = '.$flot_ticks.';
							$.plot($("#ymdw"),[{ label: "Визиты", data: visits, color:"#FCD202"},
											   { label: "Просмотры", data: views, color:"#FF7711"},
											   { label: "Посетители", data: visitors, color:"#C3B0FA"}],
								{xaxis: {ticks : ticks}, lines: { show: true },points: { show: true },grid: { backgroundColor: "#fffaff" }
							});
						});
					</script>';
				foreach (glob(MODX_BASE_PATH . 'assets/cache/ymdw.widgetCache-*.php') as $filename) {
   					unlink($filename);
				}
				file_put_contents(MODX_BASE_PATH . 'assets/cache/ymdw.widgetCache-'.date('z').'.php', $output);		
			}
		}
	}
	else{
		$output = file_get_contents( MODX_BASE_PATH . 'assets/cache/ymdw.widgetCache-'.date('z').'.php');
	}
	$e->output($output);
} 