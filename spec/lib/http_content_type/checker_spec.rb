require 'spec_helper'

require 'http_content_type/checker'

describe HttpContentType::Checker do
  let(:checker) { described_class.new('http://foo.com/bar.mp4') }

  describe '#found?' do
    context 'asset is not found' do
      before { checker.stub(:_head).and_return({ found: false }) }

      it 'return false' do
        checker.should_not be_found
      end
    end

    context 'asset is found' do
      before { checker.stub(:_head).and_return({ found: true, content_type: 'video/mp4' }) }

      it 'return true' do
        checker.should be_found
      end
    end
  end

  describe '#expected_content_type' do
    context '.mp4 video' do
      subject { described_class.new('http://foo.com/bar.mp4') }
      its(:expected_content_type) { eq 'video/mp4' }
    end

    context '.mp4 video with query params' do
      subject { described_class.new('http://foo.com/bar.mp4?foo=bar') }
      its(:expected_content_type) { eq 'video/mp4' }
    end

    context '.m4v video' do
      subject { described_class.new('http://foo.com/bar.m4v') }
      its(:expected_content_type) { eq 'video/mp4' }
    end

    context '.mov video' do
      subject { described_class.new('http://foo.com/bar.mov') }
      its(:expected_content_type) { eq 'video/mp4' }
    end

    context '.webm video' do
      subject { described_class.new('http://foo.com/bar.webm') }
      its(:expected_content_type) { eq 'video/webm' }
    end

    context '.ogg video' do
      subject { described_class.new('http://foo.com/bar.ogg') }
      its(:expected_content_type) { eq 'video/ogg' }
    end

    context '.ogv video' do
      subject { described_class.new('http://foo.com/bar.ogv') }
      its(:expected_content_type) { eq 'video/ogg' }
    end
  end

  describe '#content_type' do
    context 'fake asset has valid content type' do
      before { checker.stub(:_head).and_return({ found: true, content_type: 'video/mp4' }) }

      it 'returns the actual content type' do
        expect(checker.content_type).to eq 'video/mp4'
      end
    end

    context 'real asset has valid content type' do
      let(:checker) { described_class.new('http://player.vimeo.com/external/51920681.hd.mp4?s=70273279a571e027c54032e70db61253') }

      it 'returns the actual content type' do
        expect(checker.content_type).to eq 'video/mp4'
      end
    end
  end

  describe '#valid_content_type?' do
    context 'asset has valid content type' do
      before { checker.stub(:_head).and_return({ location: URI('http://foo.com/bar.mp4'), found: true, content_type: 'video/mp4' }) }

      it 'returns true' do
        checker.should be_valid_content_type
      end
    end

    context 'asset has invalid content type' do
      before { checker.stub(:_head).and_return({ location: URI('http://foo.com/bar.mp4'), found: true, content_type: 'video/mov' }) }

      it 'returns false' do
        checker.should_not be_valid_content_type
      end
    end
  end

  describe '#_fetch' do
    context 'too many redirections' do
      let(:response) do
        Net::HTTPRedirection.new('1.1', 302, '').tap do |res|
          res['content-type'] = 'foo/bar'
          res['location'] = 'http://domain.com/video.mp4'
        end
      end
      before { Net::HTTP.any_instance.stub(:request).and_return(response) }

      it 'raise a TooManyRedirections exception' do
        expect { checker.send(:_fetch, 'http://domain.com/video.mp4') }.to raise_error(HttpContentType::TooManyRedirections)
      end
    end
  end

end