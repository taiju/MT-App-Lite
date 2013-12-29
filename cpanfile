requires 'perl', '5.008001';
requires 'Text::Xslate', '3.1.0';
requires 'Data::Section::Simple', '0.05';
requires 'Router::Simple::Sinatraish', '0.03';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Plack::Test';
};

