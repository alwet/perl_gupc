
#!/usr/bin/perl

use warnings;
use strict;
use Mail::Sender;

my $sender = new Mail::Sender
{
  smtp    => 'smtp.163.com',
  from    => 'sstal@163.com',
  auth    => "LOGIN",
  authid  => 'sstal@163.com',
  authpwd => "vbcwygkaht"
} or die "error";


my $message = "hello , give you some message";
my $tem=`cat tem.txt`;

#if($sender-> MailMsg ({
#             to      => 'sstal@163.com',
#             subject => "test" ,
#             msg     =>  $message, })<0)
#{
#  die "$Mail::Sender::Error/n";
#}
#(ref ($sender->MailFile( {to =>'sstal@qq.com', subject => 'this is a test', msg => "Hi Johnie.\nI'm sending you the pictures you wanted.", file => 'test.pl,test1.pl' })) and print "Mail sent OK." ) or die "$Mail::Sender::Error\n";
#(ref ($sender->MailFile( {to =>'sstal@163.com', subject => 'this is a test', msg => "Hi Johnie.\nI'm sending you the pictures you wanted.", file => 'sum_20.csv' })) and print "Mail sent OK." ) or die "$Mail::Sender::Error\n";

(ref ($sender->MailFile( {to =>'sstal@163.com', subject => "this is $ARGV[0]", msg => "Hi Johnie.\nthe average is $tem\n", file => "$ARGV[0]" })) and print "Mail sent OK." ) or die "$Mail::Sender::Error\n";
$sender->Close();
