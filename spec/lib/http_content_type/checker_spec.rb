require 'spec_helper'

require 'http_content_type/checker'

describe HttpContentType::Checker do
  let(:checker) { described_class.new('http://foo.com/bar.mp4') }
  subject { checker }

  describe '#initialize' do
    it 'has default options' do
      expect(checker.options[:timeout]).to eq 5
    end

    describe ':timeout options' do
      it 'is customizable' do
        checker = described_class.new('http://foo.com/bar.mp4', timeout: 10)

        expect(checker.options[:timeout]).to eq 10
      end
    end

    describe ':expected_content_type options' do
      it 'is customizable' do
        checker = described_class.new('http://foo.com/dynamic_asset.php', expected_content_type: 'video/mp4')

        expect(checker.expected_content_type).to eq 'video/mp4'
      end
    end
  end

  describe '#error?' do
    context 'asset do not return an error' do
      before { checker.stub(:_head).and_return({ found: false, error: nil }) }

      it 'return false' do
        checker.should_not be_error
      end
    end

    context 'asset returns an error' do
      before { checker.stub(:_head).and_return({ found: false, error: true }) }

      it 'return true' do
        checker.should be_error
      end
    end
  end

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

    context 'given a hardcoded content-type' do
      subject { described_class.new('http://foo.com/dynamic_asset.php', expected_content_type: 'video/mp4') }
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
    context 'asset cannot be found and returns an error' do
      before { checker.stub(:_head).and_return({ uri: URI('http://foo.com/bar.mp4'), found: false, error: true }) }
      it { be_valid_content_type }
    end

    context 'asset cannot be found and do not return an error', :focus do
      before { checker.stub(:_head).and_return({ uri: URI('http://foo.com/bar.mp4'), found: false, error: nil }) }
      it { be_valid_content_type }
    end

    context 'asset is found without an error with valid content type', :focus do
      before { checker.stub(:_head).and_return({ uri: URI('http://foo.com/bar.mp4'), found: true, error: nil, content_type: 'video/mp4'  }) }
      it { be_valid_content_type }
    end

    context 'asset is found without an error with invalid content type', :focus do
      before { checker.stub(:_head).and_return({ uri: URI('http://foo.com/bar.mov'), found: true, error: nil, content_type: 'video/mov'  }) }
      it { be_valid_content_type }
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
