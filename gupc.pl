#!/usr/bin/perl
use strict;
use LWP::Simple;
use HTTP::Cookies;
use Encode;
use threads;
use Thread::Semaphore;
my $max_threads=1000; # $max_threads * $jmge = all number you want to find
my $bg_code=600000;
$bg_code=$ARGV[0];
$max_threads=$ARGV[1];
my $semaphore;
my @sheet;
my %old;
#&store_value(000001,000001,600100);
if(!($ARGV[0] eq 'csv')){
	$semaphore=new Thread::Semaphore($max_threads);
	&muti_thread;
}
else{
	&csv2data;
	&read_old;
	&sort_uiyingly;
}
exit;
sub read_old{
	my @line;
	open FIN,"<sum.csv" or die"diels";
	while(<FIN>){
		@line=split ",";
		if($#line>4){
			$old{"$line[1]"}=$line[0];
		}
	}
	close FIN;
}
sub muti_thread{
#    `cd gupc_data;rm -rf *;`;
    my $j=0;
    my $thread;
    my $my_job_number=$max_threads;
    my $jmge=10;
    #print localtime(time),"\n";
    while()
    {    if($j>=$my_job_number)
        {    last;
        }
        #»ñµÃÒ»¸öÐÅºÅÁ¿£»µ±Ö´ÐÐµÄÏß³ÌÊýÎª5Ê±£¬»ñÈ¡Ê§°Ü£¬Ö÷Ïß³ÌµÈ´ý¡£Ö±µ½ÓÐÒ»¸öÏß³Ì½áÊø£¬ÐÂµÄÐÅºÅÁ¿¿ÉÓÃ¡£»Ø¸´Õý³£ÔËÐÐ£»
        $semaphore->down();    #xian cheng shi fou zhixingwan
            
        #my $thread=threads->new(\&ss,$j,$j); #´´½¨Ïß³Ì£»
        my $thread=threads->new(\&store_value,$bg_code+$j*$jmge,$bg_code+($j+1)*$jmge-1,$j+$bg_code) or die "not create good\n"; #´´½¨Ïß³Ì£»
        sleep 2+0.5;
        $j=$j+1;
        $thread->detach();                #°þÀëÏß³Ì£»
    }
    #&waitquit; 
    
    #print localtime(time),"\n";
    
    #sub ss() 
    #{   my ($t,$s)=@_;
    #    sleep($t*1);
    #    #($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    #    print "$s\t",scalar(threads->list()),"\t$j\t","$sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst","\n";
    #    $semaphore->up();                  #xian cheng zhixingwanshifangxihao
    #}
    
    #À´Ô´ÓÚÔÆÊæ£¨O网页链接£￼£»
    #sub waitquit
    print "Waiting to quit...\n";
    my $num=0;
    while($num<$max_threads)
    {    $semaphore->down();
        $num++;
        print "$num thread quit...\n";
    }
    print "All $max_threads thread quit\n";
}
# Change history: use <M-c> to start recording

sub csv2data{
    my @tem;
    my @fl=`ls gupc_data/*.csv`;
    foreach(@fl){
        open FIN,"<$_" or die "dkfkkfs";
        while(<FIN>){
            chomp;
            unless(/^0$/){
                @tem=split /,/;
                push @sheet,[@tem];
            }
        }
        close FIN;
    }
}            
sub sort_uiyingly{
	my $line=1;
	my $aver=0;
	my $plming;
    @sheet=sort {@{$a}[2] <=> @{$b}[2]} @sheet; 
    open FOUT,">sum.csv" or die"ddfkkk\n";
    foreach(@sheet){
		$aver+=@{$_}[2];
		if(exists $old{@{$_}[0]}){
			$plming=$old{@{$_}[0]}-$line;
		}
		else{
			$plming='NULL';
		}
        my $tem=join ",",@{$_};
        print FOUT "$line,$tem,$plming\n";
		$line++;
    }
	my $tem=$aver/($line-1);
	#print FOUT "average:$tem\n";
	#`echo $tem > tem.txt`;
	my $tem1;
	$tem1=$line-1;
	`perl -e 'print "$tem\n";print "all lines number is $tem1";' > tem.txt`;
    close FOUT;
}
sub store_value{
    my $begin;
    my $end;
    my $f_name;
    ($begin,$end,$f_name)=@_[0..2];
    print "$begin,$end,$f_name\n";
    my $tem;
	$f_name=sprintf '%06s', $f_name; 
    open FOUT,">gupc_data/$f_name.csv" or die"dkfdkkf";
    foreach($begin..$end){
		$_=sprintf '%06s', $_; 
        my @tem=&get_value($_);
        $tem=join ",", @tem;
        print FOUT "$tem\n";
    }
    close FOUT;
    $semaphore->up();
    #foreach(@tem){
    #print "$_\n";
}
sub get_value{
    my $id=$_[0];
    my $tem=$_[0];
    if($id =~ /6\d{5}/){
        $id="sh$id";
    }
    else{
        $id="sz$id";
    }
    my $price;
    my $xiuimzguubyi=1;
    my $lirvtsbi=1;
    my $browser = LWP::UserAgent->new;
    #$browser->agent("Mozilla/5.0 (Windows NT 6.1; rv:30.0) Gecko/20100101 Firefox/30.0");
    my $res;
    #my $cookie_jar = HTTP::Cookies->new(
    #    file=>'lwp_cookies_taobao.txt',
    #    autosave=>1,
    #    ignore_discard=>1);
    #$browser->cookie_jar($cookie_jar);
    my $login_url ;
    $login_url = "https://gupiao.baidu.com/stock/$id.html";
    print "$login_url\n";
    $res = $browser->get($login_url);
    my $res_hanzi = encode("utf8", decode("gbk", $res->content));
    #$res_hanzi='<tr>	<td><b>三一重工</b></td>	<td>534亿</td>	<td>244亿</td>	<td>7.46亿</td>	<td>17.89</td>	<td>2.31</td>	<td>32.55%</td>	<td>8.66%</td>	<td>3.22%</td></tr><tr>	<td><a href="http://quote.eastmoney.com/center/list.html#28002545_0_2" target="_blank">机械行业</a><br /><b class="color979797">(行业平均)</b></td>	<td>77.1亿</td>	<td>31.8亿</td>	<td>3.71千万</td>	<td>51.87</td>	<td>2.42</td>	<td>23.32%</td>	<td>5.18%</td>	<td>4.67%</td></tr><tr>	<td><b>行业排名</b></td>	<td>2|238</td>	<td>5|238</td>	<td>3|238</td>	<td>7|238</td>	<td>60|238</td>	<td>61|238</td>	<td>88|238</td>	<td>26|238</td></tr><tr>	<td><b>四分位属性</b><b class="showRedTips hxsjccsyl" id="cwzb_sfwsxTit"><div class="sfwsx_title">四分位属性是指根据每个指标的属性，进行数值大小排序，然后分为四等分，每个部分大约包含排名的四分之一。将属性分为高、较高、较低';
    #if($res_hanzi =~ /<tr>	<td><b>三一重工<\/b><\/td>	<td>([\d\.]+)亿<\/td>	<td>([\d\.]+)亿<\/td>	<td>([\d\.]+)亿<\/td>	<td>([\d\.]+)<\/td>	<td>([\d\.]+)<\/td>	<td>([\d\.]+)%<\/td>	<td>([\d\.]+)%<\/td>	<td>([\d\.]+)%<\/td><\/tr><tr>	<td><a href=\"http:\/\/quote.eastmoney.com\/center\/list.html#28002545_0_2\" target=\"_blank\">机械行业<\/a><br \/><b class=\"color979797\">\(行业平均\)<\/b><\/td>	<td>([\d\.]+)亿<\/td>	<td>([\d\.]+)亿<\/td>	<td>([\d\.]+)千万<\/td>	<td>([\d\.]+)<\/td>	<td>([\d\.]+)<\/td>	<td>([\d\.]+)%<\/td>	<td>([\d\.]+)%<\/td>	<td>([\d\.]+)%<\/td><\/tr><tr>	<td><b>行业排名<\/b><\/td>	<td>([\d\|]+)<\/td>	<td>([\d\|]+)<\/td>	<td>([\d\|]+)<\/td>	<td>([\d\|]+)<\/td>	<td>([\d\|]+)<\/td>	<td>([\d\|]+)<\/td>	<td>([\d\|]+)<\/td>	<td>([\d\|]+)<\/td><\/tr><tr>/){
    #    #print "$1,$2,$3,$4,$5,$6,$7,$8\n";
    #    #$shiyinglv=$4;
    #}
    #else{
    #    print "NOT GET THE CORRECT PAGE\n";
    #}
    #return ($1,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10);
    #if($res_hanzi =~ /<div class=\"price s-up \"> <strong  class=\"_close\">8.29<\/strong>/six){
    #print_file('a.txt',$res_hanzi);
	my $ud;
    if($res_hanzi =~ /div class=\"price s-(\w+) \">
                        <strong  class=\"_close\">([\d\.]+)<\/strong>/){
		$ud=$1;
        $price=$2; 
    }
    else{
        print "error not get the price\n";
        return $price=0;
    }
    my $name;
    $login_url = "http://f9.eastmoney.com/$id.html#cwzb";
    print "$login_url\n";
    $res = $browser->get($login_url);
    $res_hanzi = encode("utf8", decode("gbk", $res->content));
    #print_file('a.txt',$res_hanzi);
    #if($res_hanzi=~/<title> (\S+?)\($tem\)深度F9 V1.0 /six){
    if($res_hanzi=~/(\S+?)\($tem\)深度F9 V1.0 /){
        $name=$1;
    }
    else{
        print "error not find the name\n";
        return 0;
    }
    if($res_hanzi =~ /稀释每股收益\(元\)<\/td><td>([\d\.\-]+)<\/td><td>.*净利润滚动环比增长\(%\)<\/td><td>([\d\.\-]+)<\/td><td>/){
        if($1 =~ /\-/ or $2 =~ /\-/){
            print "the incress is --\n";
            $xiuimzguubyi=1;
            $lirvtsbi=2;
			return 0;
        }
        else{
            $xiuimzguubyi=$1;
            $lirvtsbi=$2;
        }
    }
    else{
        $xiuimzguubyi=1;
        $lirvtsbi=2;
        print "error not find the incress\n";
        return 0;
    }
    #return ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24);
    if($xiuimzguubyi == 0 or $lirvtsbi == 0){
        return 0;
    }
    #return ($tem,$name,sprintf('%.6f',$price/$xiuimzguubyi/$lirvtsbi),$price,$ud,$xiuimzguubyi,$lirvtsbi);
    return ($tem,$name,sprintf('%.6f',$price/$xiuimzguubyi/sqrt($lirvtsbi)),$price,$ud,$xiuimzguubyi,$lirvtsbi);
}
sub print_file{
    #my $homepage = encode("gb2312",decode("utf-8", $res->content)); 
    my $homepage = $_[1]; 
    open FA,">@_[0]";
    print FA $homepage;
    close FA;
}
exit;
