<?php

class YandexAPI {
	var $client_id; // id приложения
	var $client_secret; // пароль приложения
	var $token; // токен, полученый в результате авторизации
	var $success = true; // bool результат успешности выполнения последней операции
	var $error = ''; // описание последней ошибки
	var $result = array(); // результат запроса
	
	
	function YandexAPI($client_id, $client_secret) {
		$this->client_id = $client_id;
		$this->client_secret = $client_secret;
	}
	
	
	// авторизация на сервисе через логин-пароль пользователя
	function LogIn($username, $password) {
		$url = 'https://oauth.yandex.ru/token';
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL,$url); // set url to post to
		curl_setopt($ch, CURLOPT_FAILONERROR, 0);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);// allow redirects
		curl_setopt($ch, CURLOPT_RETURNTRANSFER,1); // return into a variable
		curl_setopt($ch, CURLOPT_TIMEOUT, 9); 
		curl_setopt($ch, CURLOPT_POST, 1); // set POST method
		curl_setopt($ch, CURLOPT_POSTFIELDS, "grant_type=password&username={$username}&password={$password}&client_id={$this->client_id}&client_secret={$this->client_secret}"); // add POST fields
		$result = curl_exec($ch); // run the whole process 
		$status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
		curl_close($ch);  
		
		if ($status != 200) {
			$this->_error($result);
			return false;
		}
		
		$this->_success($result);
		$this->token = $this->result['access_token'];
		return true;
	}
	
	// сделать запрос
	function MakeQuery($method, $params = array()) {
		$path = "http://api-metrika.yandex.ru{$method}.json?";
		foreach ($params as $key=>$value) $path .= "{$key}={$value}&";
		$path .= "oauth_token=".$this->token;
		if (!$result = @file_get_contents($path)) {
			$this->_error();
			return false;
		}
		$this->_success($result);
		return true;
	}
	
	// вызывается после каждой успешной операции
	function _success($result) {
		$this->result = json_decode($result, true);
		$this->success = true;
		$this->error = '';
	}
	// вызывается после каждой неуспешной операции
	function _error($desc='') {
		$this->success = false;
		$this->error = json_decode($desc, true);
	}
	
}



?>