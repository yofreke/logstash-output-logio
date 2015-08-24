all: build zip

build:
	gem build logstash-output-logio.gemspec

zip:
	tar -zcvf logstash-output-logio.tar.gz logstash-output-logio-*.gem
