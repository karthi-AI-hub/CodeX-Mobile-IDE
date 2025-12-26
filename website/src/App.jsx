import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Link, useLocation } from 'react-router-dom';
import {
    Code2,
    Rocket,
    ShieldCheck,
    Smartphone,
    Zap,
    Scale,
    Menu,
    X,
    ChevronRight,
    Monitor,
    Cpu,
    Layers,
    Globe
} from 'lucide-react';

// Component to handle scroll to top on navigation
const ScrollToTop = () => {
    const { pathname } = useLocation();
    useEffect(() => {
        window.scrollTo(0, 0);
    }, [pathname]);
    return null;
};

const Navigation = ({ scrolled, isMenuOpen, setIsMenuOpen }) => (
    <nav className={`fixed top-0 w-full z-50 transition-all duration-300 ${scrolled ? 'py-3 glass border-b border-white/10' : 'py-6 bg-transparent'}`}>
        <div className="max-w-7xl mx-auto px-6 flex justify-between items-center">
            <Link
                to="/"
                className="flex items-center space-x-3 cursor-pointer group"
                onClick={() => setIsMenuOpen(false)}
            >
                <div className="relative">
                    <div className="absolute inset-0 bg-blue-500 blur-lg opacity-20 group-hover:opacity-100 transition-opacity" />
                    <img src="/logo.png" alt="CodeX" className="w-10 h-10 rounded-xl relative border border-white/10" />
                </div>
                <span className="text-2xl font-black tracking-tighter text-white">CodeX</span>
            </Link>

            <div className="hidden md:flex items-center space-x-10 text-sm font-bold tracking-tight text-zinc-400">
                <Link to="/" className="hover:text-white transition-colors">Product</Link>
                <Link to="/privacy" className="hover:text-white transition-colors">Privacy</Link>
                <Link to="/terms" className="hover:text-white transition-colors">Terms</Link>
                <a
                    href="https://play.google.com/store/apps/details?id=com.nexera.codex"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="bg-white text-black px-6 py-2.5 rounded-xl hover:bg-zinc-200 transition-all font-black"
                >
                    DOWNLOAD
                </a>
            </div>

            <button className="md:hidden text-white" onClick={() => setIsMenuOpen(!isMenuOpen)}>
                {isMenuOpen ? <X size={28} /> : <Menu size={28} />}
            </button>
        </div>

        {isMenuOpen && (
            <div className="md:hidden absolute top-full left-0 w-full bg-black/95 backdrop-blur-xl border-b border-white/10 p-8 space-y-6 flex flex-col items-center">
                <Link to="/" onClick={() => setIsMenuOpen(false)} className="text-xl font-bold">Home</Link>
                <Link to="/privacy" onClick={() => setIsMenuOpen(false)} className="text-xl font-bold">Privacy</Link>
                <Link to="/terms" onClick={() => setIsMenuOpen(false)} className="text-xl font-bold">Terms</Link>
                <a href="https://play.google.com/store/apps/details?id=com.nexera.codex" className="w-full text-center bg-blue-600 text-white py-4 rounded-xl font-bold">Get App</a>
            </div>
        )}
    </nav>
);

const Footer = () => (
    <footer className="py-20 px-6 border-t border-white/5 bg-black">
        <div className="max-w-7xl mx-auto">
            <div className="flex flex-col md:flex-row justify-between items-center mb-12">
                <div className="flex items-center space-x-3 mb-8 md:mb-0">
                    <img src="/logo.png" alt="CodeX" className="w-8 h-8 rounded-lg grayscale opacity-50" />
                    <span className="text-lg font-bold text-zinc-500 uppercase tracking-widest">CodeX Mobile IDE</span>
                </div>
                <div className="flex space-x-12 text-sm text-zinc-500 font-bold uppercase tracking-wide">
                    <Link to="/privacy" className="hover:text-white transition-colors">Privacy</Link>
                    <Link to="/terms" className="hover:text-white transition-colors">Terms</Link>
                    <a href="mailto:karthi.nexgen.dev@gmail.com" className="hover:text-white transition-colors">Support</a>
                </div>
            </div>
            <div className="pt-8 border-t border-white/5 text-center md:text-left">
                <p className="text-xs text-zinc-600 font-medium">© 2025 CodeX Team. Crafted for professional developers. Licensed under MIT.</p>
            </div>
        </div>
    </footer>
);

const Home = () => {
    const structuredData = {
        "@context": "https://schema.org",
        "@type": "SoftwareApplication",
        "name": "CodeX Mobile IDE",
        "operatingSystem": "Android, iOS",
        "applicationCategory": "DeveloperApplication",
        "offers": {
            "@type": "Offer",
            "price": "0",
            "priceCurrency": "USD"
        },
        "description": "Professional Mobile IDE and Code Editor with desktop-grade syntax highlighting and live preview.",
        "author": {
            "@type": "Person",
            "name": "Karthi-Nexgen"
        }
    };

    const screenshots = [
        { src: '/screenshot1.jpeg', alt: 'CodeX Mobile IDE Dashboard - Manage Projects' },
        { src: '/screenshot2.jpeg', alt: 'Mobile VS Code Editor - Professional Syntax Highlighting' },
        { src: '/screenshot3.jpeg', alt: 'Mobile Code Editor for Android - VS Code Interface' },
        { src: '/screenshot4.jpeg', alt: 'CodeX IDE - Multi-language support on mobile' },
        { src: '/screenshot5.jpeg', alt: 'Live Web Preview for Mobile Development' },
        { src: '/screenshot6.jpeg', alt: 'CodeX - Professional Mobile Coding Environment' }
    ];

    const features = [
        {
            icon: <Zap className="w-6 h-6 text-blue-400" />,
            title: "Turbo Performance",
            desc: "Instant file loading and zero-latency code editing even with thousands of lines of code.",
            size: "col-span-1 md:col-span-2"
        },
        {
            icon: <Code2 className="w-6 h-6 text-blue-400" />,
            title: "Intelligent Syntax",
            desc: "Desktop-grade highlighting for HTML, CSS, JS and more.",
            size: "col-span-1"
        },
        {
            icon: <Monitor className="w-6 h-6 text-blue-400" />,
            title: "Live Preview",
            desc: "See your changes instantly with a built-in web browser for rapid testing.",
            size: "col-span-1"
        },
        {
            icon: <Smartphone className="w-6 h-6 text-blue-400" />,
            title: "True Mobility",
            desc: "A custom symbols toolbar designed natively for touch devices.",
            size: "col-span-1 md:col-span-2"
        },
        {
            icon: <ShieldCheck className="w-6 h-6 text-blue-400" />,
            title: "Zero Permissions",
            desc: "Maximum privacy. No invasive data collection, works 100% offline.",
            size: "col-span-1 md:col-span-2"
        }
    ];

    return (
        <div className="min-h-screen bg-black text-white selection:bg-blue-500/30">
            <script type="application/ld+json">
                {JSON.stringify(structuredData)}
            </script>
            {/* Hero Section */}
            <section className="relative pt-[200px] pb-32 px-6 overflow-hidden">
                <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full max-w-7xl h-full -z-10">
                    <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-blue-600/20 blur-[150px] rounded-full" />
                    <div className="absolute bottom-0 left-0 w-[500px] h-[500px] bg-indigo-600/10 blur-[150px] rounded-full" />
                </div>

                <div className="max-w-7xl mx-auto text-center relative">
                    <div className="inline-flex items-center space-x-2 px-4 py-2 rounded-full glass border-white/5 text-[10px] font-black uppercase tracking-[0.2em] text-blue-400 mb-12 animate-fade-in">
                        <Rocket size={14} className="mr-2" />
                        <span>The Power of VS Code on Android</span>
                    </div>

                    <h1 className="text-7xl md:text-[130px] font-black mb-10 tracking-tighter leading-[0.85] animate-float">
                        The IDE That <br />
                        <span className="text-gradient">Travels With You.</span>
                    </h1>

                    <p className="text-zinc-400 text-lg md:text-2xl max-w-3xl mx-auto mb-16 leading-relaxed font-semibold tracking-tight">
                        Stop compromising on mobile development. CodeX brings desktop-grade performance,
                        professional syntax highlighting, and instant live previews to your pocket.
                    </p>

                    <div className="flex flex-col sm:flex-row justify-center items-center space-y-4 sm:space-y-0 sm:space-x-6">
                        <a
                            href="https://play.google.com/store/apps/details?id=com.nexera.codex"
                            target="_blank"
                            rel="noopener noreferrer"
                            className="w-full sm:w-auto px-12 py-5 bg-white text-black font-black rounded-2xl hover:scale-105 active:scale-95 transition-all text-xl shadow-2xl shadow-blue-500/20 flex items-center justify-center"
                        >
                            Get it on Play Store
                        </a>
                        <button
                            onClick={() => document.getElementById('features')?.scrollIntoView({ behavior: 'smooth' })}
                            className="w-full sm:w-auto px-12 py-5 glass text-white font-black rounded-2xl hover:bg-white/10 active:scale-95 transition-all text-xl"
                        >
                            Explore Features
                        </button>
                    </div>
                </div>
            </section>

            {/* Auto-scrolling Gallery Section */}
            <section className="py-20 bg-zinc-950 overflow-hidden">
                <div className="text-center mb-16 px-6">
                    <h2 className="text-zinc-500 text-sm font-black uppercase tracking-[0.3em] mb-4">Sneak Peek</h2>
                    <p className="text-3xl font-black">Crafted for Professionals.</p>
                </div>

                <div className="relative group pause-on-hover px-4">
                    <div className="animate-marquee flex gap-8 py-4">
                        {[...screenshots, ...screenshots].map((img, i) => (
                            <div
                                key={i}
                                className="h-[500px] md:h-[600px] aspect-[9/19] rounded-[32px] md:rounded-[48px] overflow-hidden border-4 md:border-8 border-zinc-900 shadow-2xl relative flex-shrink-0"
                            >
                                <img src={img.src} alt={img.alt} className="w-full h-full object-cover" />
                                <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent" />
                            </div>
                        ))}
                    </div>
                    <div className="absolute inset-y-0 left-0 w-32 bg-gradient-to-r from-zinc-950 to-transparent z-10" />
                    <div className="absolute inset-y-0 right-0 w-32 bg-gradient-to-l from-zinc-950 to-transparent z-10" />
                </div>
            </section>

            {/* Bento Grid Features */}
            <section id="features" className="py-32 px-6 relative">
                <div className="max-w-7xl mx-auto">
                    <div className="mb-20">
                        <h2 className="text-4xl md:text-6xl font-black mb-6 tracking-tighter">Everything you need, <br />built in natively.</h2>
                        <p className="text-zinc-500 text-xl font-bold">Standard web technologies. Professional results.</p>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
                        {features.map((f, i) => (
                            <div key={i} className={`p-10 rounded-[40px] glass hover:border-blue-500/20 transition-all flex flex-col justify-between group ${f.size}`}>
                                <div className="mb-12">
                                    <div className="p-4 bg-blue-500/10 rounded-2xl w-fit mb-8 group-hover:scale-110 transition-transform">
                                        {f.icon}
                                    </div>
                                    <h3 className="text-3xl font-black mb-4 tracking-tight">{f.title}</h3>
                                    <p className="text-zinc-500 font-bold text-lg leading-relaxed">{f.desc}</p>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* Stats Section */}
            <section className="py-32 px-6">
                <div className="max-w-7xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-12 text-center">
                    <div>
                        <div className="text-5xl font-black text-white mb-2 tracking-tighter">100%</div>
                        <div className="text-zinc-500 font-bold text-sm uppercase tracking-widest">Offline</div>
                    </div>
                    <div>
                        <div className="text-5xl font-black text-white mb-2 tracking-tighter">60FPS</div>
                        <div className="text-zinc-500 font-bold text-sm uppercase tracking-widest">Performance</div>
                    </div>
                    <div>
                        <div className="text-5xl font-black text-white mb-2 tracking-tighter">0.0</div>
                        <div className="text-zinc-500 font-bold text-sm uppercase tracking-widest">Permissions</div>
                    </div>
                    <div>
                        <div className="text-5xl font-black text-white mb-2 tracking-tighter">∞</div>
                        <div className="text-zinc-500 font-bold text-sm uppercase tracking-widest">Possibilities</div>
                    </div>
                </div>
            </section>

            {/* Final CTA */}
            <section className="py-40 px-6 relative">
                <div className="absolute inset-0 bg-blue-600/10 blur-[200px] -z-10" />
                <div className="max-w-5xl mx-auto p-12 md:p-32 rounded-[60px] bg-gradient-to-br from-zinc-900 to-black border border-white/5 relative overflow-hidden text-center">
                    <h2 className="text-5xl md:text-8xl font-black mb-12 tracking-tighter leading-[0.9]">Start building <br />on the go.</h2>
                    <p className="text-zinc-500 text-xl md:text-2xl font-bold mb-16 max-w-2xl mx-auto">
                        Ready to experience the future of mobile development?
                        Download CodeX today.
                    </p>
                    <a
                        href="https://play.google.com/store/apps/details?id=com.nexera.codex"
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center px-12 py-6 bg-blue-600 text-white rounded-[32px] font-black text-2xl hover:bg-blue-500 transition-all hover:scale-105 shadow-2xl shadow-blue-600/30"
                    >
                        FREE DOWNLOAD
                        <Rocket className="ml-3" size={24} />
                    </a>
                </div>
            </section>
        </div>
    );
};

const Privacy = () => (
    <div className="min-h-screen bg-black">
        <main className="max-w-4xl mx-auto pt-44 pb-32 px-6">
            <h1 className="text-6xl font-black text-white mb-12 tracking-tighter">Privacy Policy</h1>
            <div className="space-y-12 text-zinc-400 text-lg leading-relaxed">
                <section>
                    <h2 className="text-2xl font-bold text-white mb-4">1. Zero Data Collection</h2>
                    <p>CodeX is built on a "Privacy by Design" philosophy. We do not collect, process, or store any of your personal data, code, or project information outside of your own device. There are no tracking scripts, analytics, or background data transmissions.</p>
                </section>
                <section>
                    <h2 className="text-2xl font-bold text-white mb-4">2. Zero Permissions Policy</h2>
                    <p>CodeX is designed to be fully functional without requiring any invasive system permissions. We do not access your contacts, location, camera, or any other personal system APIs. The app operates entirely within its own secure sandbox on your device.</p>
                </section>
                <section>
                    <h2 className="text-2xl font-bold text-white mb-4">3. Absolute Privacy</h2>
                    <p>All your creative work, intellectual property, and project files remain 100% under your control on your physical device at all times. We have no access to your code, and we never will.</p>
                </section>
                <section>
                    <h2 className="text-2xl font-bold text-white mb-4">4. Contact Information</h2>
                    <p>For any privacy-related questions or support inquiries, please contact the developer team at <a href="mailto:karthi.nexgen.dev@gmail.com" className="text-blue-400 hover:underline">karthi.nexgen.dev@gmail.com</a>.</p>
                </section>
            </div>
        </main>
    </div>
);

const Terms = () => (
    <div className="min-h-screen bg-black">
        <main className="max-w-4xl mx-auto pt-44 pb-32 px-6">
            <h1 className="text-6xl font-black text-white mb-12 tracking-tighter">Terms of Service</h1>
            <div className="space-y-12 text-zinc-400 text-lg leading-relaxed">
                <section>
                    <h2 className="text-2xl font-bold text-white mb-4">1. License & Usage</h2>
                    <p>CodeX is provided "as is" under the MIT License. You are granted permission to use the software for personal and commercial development. Redistribution of the software itself is governed by the terms of the license.</p>
                </section>
                <section>
                    <h2 className="text-2xl font-bold text-white mb-4">2. Limitation of Liability</h2>
                    <p>The developers of CodeX are not responsible for any data loss, project corruption, or productivity loss that may occur through the use of the application. Users are encouraged to maintain external backups of critical codebases.</p>
                </section>
                <section>
                    <h2 className="text-2xl font-bold text-white mb-4">3. Compliance</h2>
                    <p>By using CodeX, you agree to comply with all applicable local and international laws regarding software usage and data protection.</p>
                </section>
            </div>
        </main>
    </div>
);

const App = () => {
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const [scrolled, setScrolled] = useState(false);

    useEffect(() => {
        const handleScroll = () => setScrolled(window.scrollY > 50);
        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    return (
        <Router>
            <ScrollToTop />
            <div className="flex flex-col min-h-screen bg-black">
                <Navigation scrolled={scrolled} isMenuOpen={isMenuOpen} setIsMenuOpen={setIsMenuOpen} />
                <Routes>
                    <Route path="/" element={<Home />} />
                    <Route path="/privacy" element={<Privacy />} />
                    <Route path="/terms" element={<Terms />} />
                </Routes>
                <Footer />
            </div>
        </Router>
    );
};

export default App;
