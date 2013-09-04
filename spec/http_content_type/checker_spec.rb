require 'spec_helper'

require 'http_content_type/checker'

describe HttpContentType::Checker do
  let(:checker) { described_class.new('http://foo.com/bar.mp4') }

  describe '#found?' do
    context 'asset is not found' do
      before { checker.stub(:_head).and_return({ 'found' => false }) }

      it 'return false' do
        checker.should_not be_found
      end
    end

    context 'asset is found' do
      before { checker.stub(:_head).and_return({ 'found' => true, 'content-type' => 'video/mp4' }) }

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
    context 'asset has valid content type' do
      before { checker.stub(:_head).and_return({ 'found' => true, 'content-type' => 'video/mp4' }) }

      it 'returns the actual content type' do
        expect(checker.content_type).to eq 'video/mp4'
      end
    end
  end

  describe '#valid_content_type?' do
    context 'asset has valid content type' do
      before { checker.stub(:_head).and_return({ 'found' => true, 'content-type' => 'video/mp4' }) }

      it 'returns true' do
        checker.should be_valid_content_type
      end
    end

    context 'asset has invalid content type' do
      before { checker.stub(:_head).and_return({ 'found' => true, 'content-type' => 'video/mov' }) }

      it 'returns false' do
        checker.should_not be_valid_content_type
      end
    end
  end

end
