//<?php
/**
 * Yandex Metrika Dashboard Widget
 *
 * show Visitors, Visits and Pagevisits
 *
 * @category    plugin
 * @version     0.2
 * @license     http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @package     modx
 * @author      Dmi3yy (dmi3yy@gmail.com), Pathologic (maxx@np.by)
 * @internal    @events OnManagerWelcomePrerender
 * @internal    @modx_category Manager and Admin
 * @internal    @properties &app_id = Id приложения;text; &app_pass = Пароль приложения;text; &ym_login = Логин Яндекс;text; &ym_pass = Пароль Яндекс;text; &counter_id = Номер счетчика;text; &counter_range = Количество дней;text;10 &widget_height = Высота виджета;text;350 &rotate_xlabels = Поворот подписей оси X;text;-90
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
					<script language="javascript" type="text/javascript" src="../assets/plugins/ymdw/jquery.flot.spline.min.js"></script>
					<style>
					.flot-x-axis .flot-tick-label {
					-o-transform: rotate('.$rotate_xlabels.'deg);
					-webkit-transform: rotate('.$rotate_xlabels.'deg);
					-moz-transform: rotate('.$rotate_xlabels.'deg);
					-ms-transform: rotate('.$rotate_xlabels.'deg);
  					transform: rotate('.$rotate_xlabels.'deg);
					padding:25px;
					}
					</style>
					<script type="text/javascript">
						$(document).ready(function() {
							var visitors = '.$flot_data_visitors.';
							var visits = '.$flot_data_visits.';
							var views = '.$flot_data_views.';
							var ticks = '.$flot_ticks.';
							$.plot($("#ymdw"),[{ label: "Визиты", data: visits, color:"#FCD202", lines: {show: false}, splines: {show: true, tension: 0.4}},
											   { label: "Просмотры", data: views, color:"#FF7711", lines: {show: false}, splines: {show: true, tension: 0.4}},
											   { label: "Посетители", data: visitors, color:"#C3B0FA", lines: {show: false}, splines: {show: true, tension: 0.4}}],
								{xaxis: {ticks : ticks}, points: { show: true },grid: {hoverable: true, backgroundColor: "#fffaff" }, legend: {margin: [20,10]}
							});
							function showTooltip(x, y, contents) {
								$("<div id=\'tooltip\'>" + contents + "</div>").css({
									position: "absolute",
									"z-index": 100,
									display: "none",
									top: y + 5,
									border: "1px solid #fdd",
									padding: "10px",
									"background-color": "#fee",
									opacity: 0.80
									}).appendTo("body");
									w = $("#tooltip").width();
									ow = $(".flot-base").width();
									x = (x + w + 5 > ow) ? (x - w - 10) : (x + 5);
									$("#tooltip").css("left",x).fadeIn(200);
								}

							var previousPoint = null;
							$("#ymdw").bind("plothover", function (event, pos, item) {
								if (item) {
									if (previousPoint != item.dataIndex) {
										previousPoint = item.dataIndex;
										$("#tooltip").remove();
										y = item.datapoint[1];
										showTooltip(item.pageX, item.pageY,
										item.series.label + ": " + y);
									}
								} else {
									$("#tooltip").remove();
									previousPoint = null;            
								}
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