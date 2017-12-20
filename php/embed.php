<?php

require_once 'servlet.php';

class embed implements \hi\servlet {

    public function handler(\hi\request &$req, \hi\response &$res) {
        $res->content = 'hello,world';
        $res->status = 200;
    }

}
